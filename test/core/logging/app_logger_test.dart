import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_starter/core/config/app_config.dart';
import 'package:flutter_starter/core/logging/app_logger.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';

void main() {
  setUp(AppConfig.resetForTesting);
  tearDown(AppConfig.resetForTesting);

  test('should create and provide the configured logger', () {
    AppConfig.init('dev', apiBaseUrl: 'http://localhost:8080');
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(createLogger(), isA<Logger>());
    expect(container.read(loggerProvider), isA<Logger>());
  });
}
