import 'package:flutter_starter/features/privacy/presentation/privacy_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/helpers.dart';

void main() {
  testWidgets('should require explicit analytics consent', (tester) async {
    await tester.pumpApp(const PrivacyScreen());

    expect(find.text('Share usage analytics'), findsOneWidget);
    expect(find.text('Delete local data'), findsOneWidget);

    await tester.tap(find.text('Share usage analytics'));
    await tester.pump();

    expect(tester.widgetList(find.byType(PrivacyScreen)), isNotEmpty);
  });
}
