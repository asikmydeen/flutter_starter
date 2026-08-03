/// Golden (screenshot) test — the closest thing to automated visual
/// verification without a device.
///
/// Tagged `golden` and excluded from the default CI run because rendering
/// differs subtly across host platforms. Regenerate after intentional UI
/// changes with:
///   flutter test --update-goldens --tags golden
@Tags(['golden'])
library;

import 'package:flutter_starter/features/home/presentation/home_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/helpers.dart';

void main() {
  testWidgets('home screen matches golden', (tester) async {
    await tester.pumpApp(const HomeScreen());
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(HomeScreen),
      matchesGoldenFile('goldens/home_screen.png'),
    );
  });
}
