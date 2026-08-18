import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_starter/features/privacy/application/consent_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('should disable analytics until explicit consent', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(consentControllerProvider), isFalse);

    container.read(consentControllerProvider.notifier).analyticsConsent = true;

    expect(container.read(consentControllerProvider), isTrue);
  });
}
