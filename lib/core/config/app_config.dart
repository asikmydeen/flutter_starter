/// App-wide environment configuration.
///
/// Values are selected by the `ENV` compile-time define:
///   flutter run --dart-define=ENV=dev
class AppConfig {
  AppConfig._(this.env, this.apiBaseUrl, this.enableLogging);

  final String env;
  final String apiBaseUrl;
  final bool enableLogging;

  static late AppConfig instance;

  static void init(String env) {
    switch (env) {
      case 'prod':
        instance = AppConfig._('prod', 'https://api.example.com', false);
      case 'staging':
        instance = AppConfig._('staging', 'https://staging.api.example.com', true);
      case 'dev':
      default:
        instance = AppConfig._('dev', 'https://dev.api.example.com', true);
    }
  }

  static bool get isProd => instance.env == 'prod';
}
