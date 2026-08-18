/// Mutations are centralized so dry-run can prove it performs none.
abstract interface class ReadinessEffects {
  Future<void> createGithubEnvironment(String name);
  Future<void> setGithubSecret(String environment, String name, String value);
}

/// Records the mutation plan and never changes local or remote state.
final class DryRunEffects implements ReadinessEffects {
  final List<String> _plan = [];

  /// Immutable redacted plan entries.
  List<String> get plan => List.unmodifiable(_plan);

  @override
  Future<void> createGithubEnvironment(String name) async {
    _plan.add('create-or-validate GitHub environment: $name');
  }

  @override
  Future<void> setGithubSecret(
    String environment,
    String name,
    String value,
  ) async {
    _plan.add('set GitHub environment secret: $environment/$name');
  }
}
