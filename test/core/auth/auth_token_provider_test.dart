import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_starter/core/auth/auth_token_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('should provide no token before Firebase is configured', () async {
    const provider = UnauthenticatedTokenProvider();

    expect(await provider.getIdToken(), isNull);
    expect(await provider.getIdToken(forceRefresh: true), isNull);
    await expectLater(provider.signOut(), completes);
  });

  test('should expose the safe unauthenticated provider by default', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(
      container.read(authTokenProvider),
      isA<UnauthenticatedTokenProvider>(),
    );
  });
}
