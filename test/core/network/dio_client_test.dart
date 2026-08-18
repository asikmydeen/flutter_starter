import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_starter/core/config/app_config.dart';
import 'package:flutter_starter/core/network/dio_client.dart';
import 'package:flutter_starter/core/network/safe_network_log_interceptor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(AppConfig.resetForTesting);
  tearDown(AppConfig.resetForTesting);

  test('should configure timeouts and safe logging in development', () {
    AppConfig.init('dev', apiBaseUrl: 'http://localhost:8080');
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final dio = container.read(dioProvider);

    expect(dio.options.baseUrl, 'http://localhost:8080');
    expect(dio.options.connectTimeout, const Duration(seconds: 15));
    expect(dio.options.receiveTimeout, const Duration(seconds: 15));
    expect(
      dio.interceptors.whereType<SafeNetworkLogInterceptor>().single,
      isA<SafeNetworkLogInterceptor>(),
    );
  });

  test('should disable network logging in production', () {
    AppConfig.init('prod', apiBaseUrl: 'https://api.company.dev');
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(
      container
          .read(dioProvider)
          .interceptors
          .whereType<SafeNetworkLogInterceptor>(),
      isEmpty,
    );
  });
}
