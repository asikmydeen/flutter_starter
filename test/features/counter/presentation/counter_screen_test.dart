import 'package:flutter/material.dart';
import 'package:flutter_starter/features/counter/presentation/counter_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/helpers.dart';

void main() {
  testWidgets('should increment and decrement with labeled controls', (
    tester,
  ) async {
    await tester.pumpApp(const CounterScreen());

    expect(find.text('0'), findsOneWidget);
    expect(find.byTooltip('Increment counter'), findsOneWidget);
    expect(find.byTooltip('Decrement counter'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(find.text('1'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.remove));
    await tester.pump();
    expect(find.text('0'), findsOneWidget);
  });
}
