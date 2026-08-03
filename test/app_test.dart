import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_starter/app.dart';
import 'package:flutter_starter/features/home/presentation/home_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/helpers.dart';

/// App-level smoke test: the full widget tree (router, theme, l10n)
/// builds and lands on the home screen.
void main() {
  setUp(setUpTestConfig);

  testWidgets('app boots to the home screen', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
