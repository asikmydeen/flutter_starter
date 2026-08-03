/// App-wide environment configuration.
///
/// Values are selected by the `ENV` compile-time define:
///   flutter run --dart-define=ENV=dev
///
/// Never read `String.fromEnvironment` anywhere else in the app — all
/// env-dependent values flow through this class.
class AppConfig {
  AppConfig._({
    required this.env,
    required this.apiBaseUrl,
    required this.enableLogging,
  });

  /// One of [validEnvs].
  final String env;

  /// Base URL used by the dio client.
  final String apiBaseUrl;

  /// Whether verbose network/app logging is enabled.
  final bool enableLogging;

  /// The environments this app knows about.
  static const validEnvs = ['dev', 'staging', 'prod'];

  static AppConfig? _instance;

  /// The active configuration. Throws a descriptive error if [init] was
  /// not called first — fail loud, fail early.
  static AppConfig get instance {
    final config = _instance;
    if (config == null) {
      throw StateError(
        'AppConfig.instance accessed before AppConfig.init(). '
        'Call AppConfig.init(env) in main()/bootstrap() before runApp(). '
        'In tests, call AppConfig.init("dev") in setUp().',
      );
    }
    return config;
  }

  /// Selects the configuration for [env]. Must be called exactly once
  /// before the app (or a test that touches config) runs.
  ///
  /// Throws [ArgumentError] on an unknown environment instead of silently
  /// falling back — a wrong `--dart-define` should break the build, not
  /// ship pointing at the wrong backend.
  static void init(String env) {
    _instance = switch (env) {
      'prod' => AppConfig._(
        env: 'prod',
        apiBaseUrl: 'https://api.example.com',
        enableLogging: false,
      ),
      'staging' => AppConfig._(
        env: 'staging',
        apiBaseUrl: 'https://staging.api.example.com',
        enableLogging: true,
      ),
      'dev' => AppConfig._(
        env: 'dev',
        apiBaseUrl: 'https://dev.api.example.com',
        enableLogging: true,
      ),
      _ => throw ArgumentError.value(
        env,
        'env',
        'Unknown environment. Valid values: ${validEnvs.join(", ")}. '
            'Pass one with --dart-define=ENV=<value>.',
      ),
    };
  }

  /// Resets state between tests. Not for production use.
  static void resetForTesting() => _instance = null;

  /// True when running against production config.
  static bool get isProd => instance.env == 'prod';
}
