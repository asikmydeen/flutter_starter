import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_starter/core/config/app_config.dart';
import 'package:flutter_starter/core/logging/app_logger.dart';

/// Initializes config and global error handling, then runs the app.
///
/// All entry points go through here so error reporting is wired exactly
/// once. To add crash reporting (Crashlytics/Sentry), forward errors from
/// the three handlers below — do not add handlers anywhere else.
Future<void> bootstrap(
  Widget Function() builder, {
  String? environment,
  String? apiUrl,
}) async {
  // Both values are mandatory so release builds cannot fall back to dev.
  const compiledEnv = String.fromEnvironment('ENV');
  const compiledApiBaseUrl = String.fromEnvironment('API_BASE_URL');
  final env = environment ?? compiledEnv;
  final apiBaseUrl = apiUrl ?? compiledApiBaseUrl;
  AppConfig.init(env, apiBaseUrl: apiBaseUrl);

  final logger = createLogger();

  // Framework errors (build/layout/paint).
  FlutterError.onError = (details) {
    logger.e(
      'FlutterError: ${details.exceptionAsString()}',
      error: details.exception,
      stackTrace: details.stack,
    );
    // In debug, also dump to console with the standard red formatting.
    if (kDebugMode) FlutterError.presentError(details);
  };

  // Errors from the underlying platform/engine that escape the zone.
  PlatformDispatcher.instance.onError = (error, stack) {
    logger.f('Uncaught platform error', error: error, stackTrace: stack);
    return true; // handled — prevents the engine from crashing the app
  };

  // Errors from async code outside the Flutter framework.
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      runApp(ProviderScope(child: builder()));
    },
    (error, stack) {
      logger.f('Uncaught zone error', error: error, stackTrace: stack);
    },
  );
}
