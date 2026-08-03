import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_starter/core/config/app_config.dart';
import 'package:logger/logger.dart';

/// Single app-wide logger. Inject via [loggerProvider]; in plain classes
/// accept a [Logger] constructor parameter so tests can pass a fake.
final loggerProvider = Provider<Logger>((ref) => createLogger());

/// Creates the configured logger. Kept as a top-level function so
/// bootstrap (which runs before any ProviderScope exists) can use it too.
Logger createLogger() {
  return Logger(
    level: AppConfig.instance.enableLogging ? Level.debug : Level.warning,
    printer: PrettyPrinter(
      methodCount: 0,
      dateTimeFormat: DateTimeFormat.onlyTime,
    ),
  );
}
