import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Auth SDK boundary used by networking without persisting token values.
abstract interface class AuthTokenProvider {
  /// Returns the current ID token, optionally forcing an SDK refresh.
  Future<String?> getIdToken({bool forceRefresh = false});

  /// Ends the current session after terminal authentication failure.
  Future<void> signOut();
}

/// Default before Firebase is configured. Requests remain unauthenticated.
final class UnauthenticatedTokenProvider implements AuthTokenProvider {
  const UnauthenticatedTokenProvider();

  @override
  Future<String?> getIdToken({bool forceRefresh = false}) async => null;

  @override
  Future<void> signOut() async {}
}

/// Replace with the Firebase adapter during M2 runtime initialization.
final authTokenProvider = Provider<AuthTokenProvider>(
  (ref) => const UnauthenticatedTokenProvider(),
);
