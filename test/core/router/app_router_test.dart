import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_starter/app.dart';
import 'package:flutter_starter/core/router/app_router.dart';
import 'package:flutter_starter/features/counter/presentation/counter_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/helpers.dart';

void main() {
  setUp(setUpTestConfig);

  testWidgets('should navigate by route name and localize unknown routes', (
    tester,
  ) async {
    final container = ProviderContainer(retry: (_, _) => null);
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const MyApp()),
    );
    await tester.pumpAndSettle();
    final router = container.read(routerProvider)..goNamed(RouteNames.counter);
    await tester.pumpAndSettle();
    expect(find.byType(CounterScreen), findsOneWidget);

    router.go('/missing');
    await tester.pumpAndSettle();
    expect(find.textContaining('Route not found'), findsOneWidget);
  });
}
