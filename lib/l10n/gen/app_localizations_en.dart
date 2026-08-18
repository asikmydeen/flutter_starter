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
  String get openDiagnosticsButton => 'Open diagnostics';

  @override
  String get openPrivacyButton => 'Open privacy settings';

  @override
  String get diagnosticsTitle => 'Diagnostics';

  @override
  String get environmentLabel => 'Environment';

  @override
  String get apiHostLabel => 'API host';

  @override
  String get privacyTitle => 'Privacy';

  @override
  String get analyticsConsentTitle => 'Share usage analytics';

  @override
  String get analyticsConsentDescription =>
      'Help improve the app with consent-controlled, non-sensitive usage data.';

  @override
  String get deleteLocalDataTitle => 'Delete local data';

  @override
  String get deleteLocalDataDescription =>
      'Signing out or deleting the account removes account-scoped local data.';

  @override
  String get counterTitle => 'Counter';

  @override
  String get incrementCounter => 'Increment counter';

  @override
  String get decrementCounter => 'Decrement counter';

  @override
  String get todosTitle => 'Todos';

  @override
  String get retryButton => 'Retry';

  @override
  String get networkError =>
      'Could not reach the server. Check your connection.';

  @override
  String apiError(int statusCode) {
    return 'The server returned an error ($statusCode).';
  }

  @override
  String get parsingError => 'Received an unexpected response format.';

  @override
  String get configurationError =>
      'The app is not configured for this environment.';

  @override
  String get authenticationError => 'Your session has expired. Sign in again.';

  @override
  String get storageError => 'The app could not save data on this device.';

  @override
  String get conflictError =>
      'This item changed elsewhere. Review both versions.';

  @override
  String get unknownError => 'Something went wrong. Please try again.';

  @override
  String routeNotFound(String uri) {
    return 'Route not found: $uri';
  }
}
