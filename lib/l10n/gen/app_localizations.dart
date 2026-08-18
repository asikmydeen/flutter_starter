import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// The application title shown in the app bar and task switcher
  ///
  /// In en, this message translates to:
  /// **'Flutter Starter'**
  String get appTitle;

  /// Tagline on the home screen
  ///
  /// In en, this message translates to:
  /// **'Feature-first + Riverpod + go_router'**
  String get homeTagline;

  /// Home screen button that navigates to the counter demo
  ///
  /// In en, this message translates to:
  /// **'Open counter demo'**
  String get openCounterButton;

  /// Home screen button that navigates to the todos reference feature
  ///
  /// In en, this message translates to:
  /// **'Open todos demo (reference feature)'**
  String get openTodosButton;

  /// Home screen button that opens diagnostics
  ///
  /// In en, this message translates to:
  /// **'Open diagnostics'**
  String get openDiagnosticsButton;

  /// Home screen button that opens privacy settings
  ///
  /// In en, this message translates to:
  /// **'Open privacy settings'**
  String get openPrivacyButton;

  /// Diagnostics screen title
  ///
  /// In en, this message translates to:
  /// **'Diagnostics'**
  String get diagnosticsTitle;

  /// Current environment label
  ///
  /// In en, this message translates to:
  /// **'Environment'**
  String get environmentLabel;

  /// Configured API host label
  ///
  /// In en, this message translates to:
  /// **'API host'**
  String get apiHostLabel;

  /// Privacy screen title
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacyTitle;

  /// Analytics consent control title
  ///
  /// In en, this message translates to:
  /// **'Share usage analytics'**
  String get analyticsConsentTitle;

  /// Analytics consent explanation
  ///
  /// In en, this message translates to:
  /// **'Help improve the app with consent-controlled, non-sensitive usage data.'**
  String get analyticsConsentDescription;

  /// Local data deletion option title
  ///
  /// In en, this message translates to:
  /// **'Delete local data'**
  String get deleteLocalDataTitle;

  /// Local data deletion behavior
  ///
  /// In en, this message translates to:
  /// **'Signing out or deleting the account removes account-scoped local data.'**
  String get deleteLocalDataDescription;

  /// App bar title of the counter screen
  ///
  /// In en, this message translates to:
  /// **'Counter'**
  String get counterTitle;

  /// Accessible label for the increment counter action
  ///
  /// In en, this message translates to:
  /// **'Increment counter'**
  String get incrementCounter;

  /// Accessible label for the decrement counter action
  ///
  /// In en, this message translates to:
  /// **'Decrement counter'**
  String get decrementCounter;

  /// App bar title of the todos screen
  ///
  /// In en, this message translates to:
  /// **'Todos'**
  String get todosTitle;

  /// Button shown under an error message to retry the failed operation
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryButton;

  /// Error shown when a network request cannot reach the server
  ///
  /// In en, this message translates to:
  /// **'Could not reach the server. Check your connection.'**
  String get networkError;

  /// Error shown when the server returns a failed status
  ///
  /// In en, this message translates to:
  /// **'The server returned an error ({statusCode}).'**
  String apiError(int statusCode);

  /// Error shown when server data cannot be parsed
  ///
  /// In en, this message translates to:
  /// **'Received an unexpected response format.'**
  String get parsingError;

  /// Error shown when required environment configuration is invalid
  ///
  /// In en, this message translates to:
  /// **'The app is not configured for this environment.'**
  String get configurationError;

  /// Error shown when authentication is required or expired
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Sign in again.'**
  String get authenticationError;

  /// Error shown when local persistence fails
  ///
  /// In en, this message translates to:
  /// **'The app could not save data on this device.'**
  String get storageError;

  /// Error shown when local and remote edits conflict
  ///
  /// In en, this message translates to:
  /// **'This item changed elsewhere. Review both versions.'**
  String get conflictError;

  /// Fallback error for an unexpected failure
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get unknownError;

  /// Error page message for unknown routes
  ///
  /// In en, this message translates to:
  /// **'Route not found: {uri}'**
  String routeNotFound(String uri);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
