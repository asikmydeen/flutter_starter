import 'dart:convert';

import 'command_runner.dart';
import 'effects.dart';

/// Least-privilege GitHub environment adapter backed by `gh`.
final class GithubClient implements ReadinessEffects {
  const GithubClient({
    required this.repository,
    required this.runner,
  });

  final String repository;
  final CommandRunner runner;

  /// Validates authentication and exact repository identity.
  Future<String?> validate() async {
    final auth = await runner.run('gh', [
      'auth',
      'status',
      '--hostname',
      'github.com',
    ]);
    if (auth.exitCode != 0) return 'GitHub authentication failed';
    final repo = await runner.run('gh', [
      'repo',
      'view',
      repository,
      '--json',
      'nameWithOwner',
      '--jq',
      '.nameWithOwner',
    ]);
    if (repo.exitCode != 0 || repo.stdout.trim() != repository) {
      return 'GitHub repository identity does not match the manifest';
    }
    return null;
  }

  /// Verifies that an environment exists and has deployment protections.
  Future<String?> validateEnvironment(String name) async {
    final result = await runner.run('gh', [
      'api',
      'repos/$repository/environments/$name',
    ]);
    if (result.exitCode != 0) return 'GitHub environment is missing: $name';
    final payload = jsonDecode(result.stdout)! as Map<String, Object?>;
    final rules = payload['protection_rules'] as List<Object?>? ?? const [];
    final hasReviewers = rules.whereType<Map<String, Object?>>().any(
      (rule) => rule['type'] == 'required_reviewers',
    );
    final branchPolicy = payload['deployment_branch_policy'];
    if (!hasReviewers || branchPolicy == null) {
      return 'GitHub environment lacks reviewers or protected ref policy: '
          '$name';
    }
    return null;
  }

  @override
  Future<void> createGithubEnvironment(String name) async {
    final existing = await runner.run('gh', [
      'api',
      'repos/$repository/environments/$name',
    ]);
    if (existing.exitCode == 0) return;
    final result = await runner.run('gh', [
      'api',
      '--method',
      'PUT',
      'repos/$repository/environments/$name',
      '--input',
      '-',
    ], stdin: '{}');
    if (result.exitCode != 0) {
      throw StateError('Unable to configure GitHub environment $name');
    }
  }

  @override
  Future<void> setGithubSecret(
    String environment,
    String name,
    String value,
  ) async {
    final result = await runner.run('gh', [
      'secret',
      'set',
      name,
      '--env',
      environment,
      '--repo',
      repository,
    ], stdin: value);
    if (result.exitCode != 0) {
      throw StateError('Unable to set GitHub environment secret $name');
    }
  }
}
