import 'package:dio/dio.dart';
import 'package:flutter_starter/core/auth/auth_token_provider.dart';

/// Injects ID tokens and performs one safe forced-refresh retry after a 401.
final class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._dio, this._tokens);

  static const _retriedKey = 'authRetryAttempted';

  final Dio _dio;
  final AuthTokenProvider _tokens;

  @override
  // Dio requires a void override; the handler completes after token lookup.
  // ignore: avoid_void_async
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokens.getIdToken();
    if (token != null) options.headers['Authorization'] = 'Bearer $token';
    handler.next(options);
  }

  @override
  // Dio requires a void override; the handler completes after refresh/retry.
  // ignore: avoid_void_async
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }
    final request = err.requestOptions;
    if (request.extra[_retriedKey] == true || !_canRetry(request)) {
      await _tokens.signOut();
      handler.next(err);
      return;
    }
    final refreshedToken = await _tokens.getIdToken(forceRefresh: true);
    if (refreshedToken == null) {
      await _tokens.signOut();
      handler.next(err);
      return;
    }
    request
      ..extra[_retriedKey] = true
      ..headers['Authorization'] = 'Bearer $refreshedToken';
    try {
      handler.resolve(await _dio.fetch<dynamic>(request));
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  bool _canRetry(RequestOptions request) {
    if (const {
      'GET',
      'HEAD',
      'OPTIONS',
    }.contains(request.method.toUpperCase())) {
      return true;
    }
    return request.headers['Idempotency-Key'] != null;
  }
}
