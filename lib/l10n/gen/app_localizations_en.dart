// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Flutter Starter';

  @override
  String get homeTagline => 'Feature-first + Riverpod + go_router';

  @override
  String get openCounterButton => 'Open counter demo';

  @override
  String get openTodosButton => 'Open todos demo (reference feature)';

  @override
  String get counterTitle => 'Counter';

  @override
  String get todosTitle => 'Todos';

  @override
  String get retryButton => 'Retry';

  @override
  String routeNotFound(String uri) {
    return 'Route not found: $uri';
  }
}
