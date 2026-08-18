import 'package:flutter_starter/features/counter/presentation/counter_screen.dart';
import 'package:flutter_starter/features/home/presentation/home_screen.dart';
import 'package:flutter_starter/features/privacy/presentation/privacy_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/helpers.dart';

void main() {
  setUp(setUpTestConfig);

  for (final screen in const [
    HomeScreen(),
    CounterScreen(),
    PrivacyScreen(),
  ]) {
    testWidgets(
      'should meet labeled control and Android tap target guidance for '
      '${screen.runtimeType}',
      (tester) async {
        final semantics = tester.ensureSemantics();
        try {
          await tester.pumpApp(screen);

          await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
          await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        } finally {
          semantics.dispose();
        }
      },
      tags: ['a11y'],
    );
  }
}
