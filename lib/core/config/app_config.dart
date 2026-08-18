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
        'Call AppConfig.init(env, apiBaseUrl: url) before runApp(). '
        'In tests, use setUpTestConfig().',
      );
    }
    return config;
  }

  /// Selects the configuration for [env] and validated [apiBaseUrl].
  /// Must be called exactly once
  /// before the app (or a test that touches config) runs.
  ///
  /// Throws [ArgumentError] on an unknown environment instead of silently
  /// falling back — a wrong `--dart-define` should break the build, not
  /// ship pointing at the wrong backend.
  static void init(String env, {required String apiBaseUrl}) {
    if (!validEnvs.contains(env)) {
      throw ArgumentError.value(
        env,
        'env',
        'Unknown environment. Valid values: ${validEnvs.join(", ")}. '
            'Pass one with --dart-define=ENV=<value>.',
      );
    }
    final uri = Uri.tryParse(apiBaseUrl);
    final isLocalDev =
        env == 'dev' &&
        uri != null &&
        (uri.host == 'localhost' || uri.host == '127.0.0.1');
    final hasSecureScheme =
        uri != null &&
        (uri.scheme == 'https' || isLocalDev && uri.scheme == 'http');
    final isPlaceholder =
        uri == null ||
        uri.host.isEmpty ||
        uri.host.endsWith('.example.com') ||
        uri.host.endsWith('.example.invalid') ||
        uri.host.endsWith('.test');
    if (!hasSecureScheme || isPlaceholder) {
      throw ArgumentError.value(
        apiBaseUrl,
        'apiBaseUrl',
        'API_BASE_URL must be a configured HTTPS URL. Development may use '
            'HTTP only for localhost.',
      );
    }
    _instance = AppConfig._(
      env: env,
      apiBaseUrl: uri.toString(),
      enableLogging: env != 'prod',
    );
  }

  /// Resets state between tests. Not for production use.
  static void resetForTesting() => _instance = null;

  /// True when running against production config.
  static bool get isProd => instance.env == 'prod';
}
