import 'package:flutter_starter/features/diagnostics/presentation/diagnostics_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/helpers.dart';

void main() {
  setUp(setUpTestConfig);

  testWidgets('should show non-sensitive environment diagnostics', (
    tester,
  ) async {
    await tester.pumpApp(const DiagnosticsScreen());

    expect(find.text('Environment'), findsOneWidget);
    expect(find.text('dev'), findsOneWidget);
    expect(find.text('API host'), findsOneWidget);
    expect(find.text('localhost'), findsOneWidget);
  });
}
