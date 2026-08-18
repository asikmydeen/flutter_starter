import 'package:flutter_starter/core/config/app_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppConfig', () {
    setUp(AppConfig.resetForTesting);
    tearDown(AppConfig.resetForTesting);

    test('should throw a descriptive StateError when accessed before init', () {
      expect(
        () => AppConfig.instance,
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('AppConfig.init'),
          ),
        ),
      );
    });

    test('should throw ArgumentError for an unknown environment', () {
      expect(
        () => AppConfig.init(
          'production',
          apiBaseUrl: 'https://api.company.dev',
        ),
        throwsArgumentError,
      );
    });

    test('should select prod values when env is prod', () {
      AppConfig.init('prod', apiBaseUrl: 'https://api.company.dev');
      expect(AppConfig.isProd, isTrue);
      expect(AppConfig.instance.enableLogging, isFalse);
    });

    test('should enable logging when env is dev', () {
      AppConfig.init('dev', apiBaseUrl: 'http://localhost:8080');
      expect(AppConfig.isProd, isFalse);
      expect(AppConfig.instance.enableLogging, isTrue);
    });

    test('should reject missing, placeholder, and insecure URLs', () {
      expect(
        () => AppConfig.init('prod', apiBaseUrl: ''),
        throwsArgumentError,
      );
      expect(
        () => AppConfig.init('prod', apiBaseUrl: 'https://api.example.com'),
        throwsArgumentError,
      );
      expect(
        () => AppConfig.init('prod', apiBaseUrl: 'http://api.company.dev'),
        throwsArgumentError,
      );
    });
  });
}
