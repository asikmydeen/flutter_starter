import 'package:flutter/material.dart';
import 'package:flutter_starter/features/counter/presentation/counter_screen.dart';
import 'package:flutter_starter/features/diagnostics/presentation/diagnostics_screen.dart';
import 'package:flutter_starter/features/home/presentation/home_screen.dart';
import 'package:flutter_starter/features/privacy/presentation/privacy_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/helpers.dart';

void main() {
  setUp(setUpTestConfig);

  const surfaces = [
    Size(320, 568),
    Size(700, 900),
    Size(1024, 768),
    Size(844, 390),
  ];
  const screens = <Widget>[
    HomeScreen(),
    CounterScreen(),
    DiagnosticsScreen(),
    PrivacyScreen(),
  ];

  for (final surface in surfaces) {
    for (final screen in screens) {
      testWidgets(
        'should render ${screen.runtimeType} at '
        '${surface.width}x${surface.height}',
        (tester) async {
          await tester.pumpApp(
            screen,
            surfaceSize: surface,
            textScaler: const TextScaler.linear(2),
          );
          await tester.pump();

          expect(tester.takeException(), isNull);
          expect(find.byType(screen.runtimeType), findsOneWidget);
        },
        tags: ['responsive'],
      );
    }
  }

  testWidgets('should preserve Home actions in RTL', (tester) async {
    await tester.pumpApp(
      const HomeScreen(),
      surfaceSize: const Size(320, 568),
      textDirection: TextDirection.rtl,
    );

    expect(find.text('Open diagnostics'), findsOneWidget);
    expect(find.text('Open privacy settings'), findsOneWidget);
    expect(tester.takeException(), isNull);
  }, tags: ['responsive']);
}
