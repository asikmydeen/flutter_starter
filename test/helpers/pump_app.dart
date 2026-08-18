import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_starter/core/theme/app_theme.dart';
import 'package:flutter_starter/l10n/gen/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

/// The standard way to pump a widget under test.
///
/// Wraps [widget] in a `ProviderScope` + `MaterialApp` with localization
/// wired, so screens behave exactly as in the real app. Override providers
/// to substitute mocks:
///
/// ```dart
/// await tester.pumpApp(
///   const TodosScreen(),
///   overrides: [todosRepositoryProvider.overrideWithValue(mockRepo)],
/// );
/// ```
extension PumpApp on WidgetTester {
  /// Pumps [widget] inside the app shell described above.
  Future<void> pumpApp(
    Widget widget, {
    List<Override> overrides = const [],
    Size? surfaceSize,
    TextScaler textScaler = TextScaler.noScaling,
    TextDirection textDirection = TextDirection.ltr,
  }) {
    if (surfaceSize != null) {
      view
        ..physicalSize = surfaceSize
        ..devicePixelRatio = 1;
      addTearDown(() {
        view
          ..resetPhysicalSize()
          ..resetDevicePixelRatio();
      });
    }
    return pumpWidget(
      ProviderScope(
        overrides: overrides,
        // Riverpod 3 retries failed providers with backoff by default,
        // which makes error-path tests flaky. Disable for determinism.
        retry: (_, _) => null,
        child: MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: textScaler),
            child: Directionality(
              textDirection: textDirection,
              child: child!,
            ),
          ),
          home: widget,
        ),
      ),
    );
  }
}
