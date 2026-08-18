import 'package:dio/dio.dart';
import 'package:flutter_starter/core/network/safe_network_log_interceptor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('should omit headers, query values, and bodies from request logs', () {
    final messages = <String>[];
    final interceptor = SafeNetworkLogInterceptor(messages.add);
    final options = RequestOptions(
      path: '/todos',
      baseUrl: 'https://api.company.dev',
      method: 'POST',
      headers: {'Authorization': 'Bearer secret-token'},
      queryParameters: {'email': 'private@example.test'},
      data: {'password': 'secret-password'},
    );

    interceptor.onRequest(options, RequestInterceptorHandler());

    expect(messages.single, 'HTTP POST /todos started');
    expect(messages.single, isNot(contains('secret-token')));
    expect(messages.single, isNot(contains('private@example.test')));
    expect(messages.single, isNot(contains('secret-password')));
  });

  test('should log only status and timing for failures', () async {
    final messages = <String>[];
    final interceptor = SafeNetworkLogInterceptor(messages.add);
    final options = RequestOptions(
      path: '/todos',
      baseUrl: 'https://api.company.dev',
      method: 'GET',
    );
    interceptor.onRequest(options, RequestInterceptorHandler());
    final error = DioException(
      requestOptions: options,
      response: Response<dynamic>(requestOptions: options, statusCode: 401),
      type: DioExceptionType.badResponse,
      message: 'Bearer secret-token',
    );

    final handler = TestErrorInterceptorHandler();
    final forwarded = expectLater(handler.forwarded, throwsA(anything));
    interceptor.onError(error, handler);
    await forwarded;

    expect(messages.last, contains('HTTP GET /todos failed 401'));
    expect(messages.last, isNot(contains('secret-token')));
  });
}

final class TestErrorInterceptorHandler extends ErrorInterceptorHandler {
  Future<Object?> get forwarded => future;
}
