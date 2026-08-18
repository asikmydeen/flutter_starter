import 'package:dio/dio.dart';

/// Emits request metadata without headers, query values, or bodies.
final class SafeNetworkLogInterceptor extends Interceptor {
  /// Creates the interceptor with a redacted log sink.
  SafeNetworkLogInterceptor(this._write);

  final void Function(String message) _write;
  final Expando<Stopwatch> _timers = Expando<Stopwatch>();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _timers[options] = Stopwatch()..start();
    _write('HTTP ${options.method} ${options.uri.path} started');
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final options = response.requestOptions;
    final elapsed = _timers[options]?.elapsedMilliseconds;
    _write(
      'HTTP ${options.method} ${options.uri.path} '
      '${response.statusCode ?? 0} ${elapsed ?? 0}ms',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final options = err.requestOptions;
    final elapsed = _timers[options]?.elapsedMilliseconds;
    _write(
      'HTTP ${options.method} ${options.uri.path} failed '
      '${err.response?.statusCode ?? 0} ${elapsed ?? 0}ms '
      '${err.type.name}',
    );
    handler.next(err);
  }
}
