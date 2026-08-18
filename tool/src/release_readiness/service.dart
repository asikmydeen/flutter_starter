import 'dart:convert';
import 'dart:io';

import 'digest.dart';
import 'effects.dart';
import 'github_client.dart';
import 'model.dart';
import 'secret_reference.dart';
import 'state_store.dart';

/// Result of a readiness operation.
final class ReadinessOutcome {
  const ReadinessOutcome(this.state, {this.plan = const []});

  final ReadinessState state;
  final List<String> plan;
}

/// Fail-closed readiness orchestration.
final class ReleaseReadinessService {
  ReleaseReadinessService({
    required this.repositoryRoot,
    required this.store,
    required this.github,
    File? referenceFile,
  }) : referenceFile =
           referenceFile ?? File('${repositoryRoot.path}/.env.release.local');

  final Directory repositoryRoot;
  final ReadinessStateStore store;
  final GithubClient github;
  final File referenceFile;

  File get _manifestFile =>
      File('${repositoryRoot.path}/config/release_readiness.json');
  File get _starterFile => File('${repositoryRoot.path}/starter.yaml');

  Map<String, Object?> get manifest =>
      jsonDecode(_manifestFile.readAsStringSync())! as Map<String, Object?>;

  List<Map<String, Object?>> get questionnaire =>
      (manifest['questionnaire']! as List<Object?>)
          .map((item) => item! as Map<String, Object?>)
          .toList(growable: false);

  List<String> get _requiredAnswerPaths => questionnaire
      .where((question) => question['required'] == true)
      .where((question) => question['type'] != 'secretReference')
      .map((question) => question['key']! as String)
      .toList(growable: false);

  List<String> get _requiredSecretNames => questionnaire
      .where((question) => question['required'] == true)
      .where((question) => question['type'] == 'secretReference')
      .map((question) => question['key']! as String)
      .map((key) => key.substring('secret.'.length))
      .toList(growable: false);

  List<String> get _requiredEvidence =>
      (manifest['requiredEvidence']! as List<Object?>).cast<String>();

  /// Current canonical inputs digest, including local answers and evidence.
  String get currentDigest => _digestForState(store.load());

  /// Initializes resumable state without changing project/provider resources.
  ReadinessState initialize() {
    final existing = store.load();
    if (existing != null) return existing;
    var state = ReadinessState.initial(inputsDigest: _digestForState(null));
    state = _rebindDigest(state);
    store.save(state);
    return state;
  }

  /// Returns current state, initializing if necessary.
  ReadinessState status() => store.load() ?? initialize();

  /// Records a nonsecret answer, evidence value, or credential reference.
  ReadinessState answer(String key, Object? value) {
    if (key.startsWith('evidence.')) {
      throw ArgumentError(
        'Live validation evidence can only be recorded by a provider validator',
      );
    }
    if (_looksLikeCredential(value)) {
      throw ArgumentError(
        'Credential values cannot be persisted; use a file:// or keychain:// reference',
      );
    }
    var state = _refreshDigest(status());
    if (key.startsWith('secret.')) {
      if (value is! String) {
        throw ArgumentError('Secret references must be strings');
      }
      SecretReference.parse(value);
      _saveSecretReference(key.substring('secret.'.length), value);
    }
    final persistedValue = key.startsWith('secret.')
        ? '${value.toString().split('://').first} reference configured'
        : value;
    final answers = Map<String, Object?>.from(state.answers)
      ..[key] = persistedValue;
    state = state.copyWith(answers: answers, blockers: const []);
    state = _rebindDigest(state);
    store.save(state);
    return state;
  }

  /// Records the redacted result of an actual provider validator.
  ReadinessState recordValidationEvidence(
    String checkId, {
    required bool valid,
  }) {
    var state = _refreshDigest(status());
    if (!_requiredEvidence.contains(checkId)) {
      throw ArgumentError.value(checkId, 'checkId', 'Unknown validator check');
    }
    final evidence = Map<String, Object?>.from(state.evidence)
      ..[checkId] = valid;
    state = _rebindDigest(
      state.copyWith(evidence: evidence, blockers: const []),
    );
    store.save(state);
    return state;
  }

  /// Runs offline checks and optional live provider validation.
  Future<ReadinessState> validate({required bool live}) async {
    var state = _refreshDigest(status());
    final blockers = <ReadinessBlocker>[];
    final answers = _mergedAnswers(state);

    for (final path in _requiredAnswerPaths) {
      final value = _readPath(answers, path);
      if (_isMissing(path, value)) {
        blockers.add(
          ReadinessBlocker(
            kind: BlockerKind.missingInput,
            checkId: 'answer.$path',
            message: 'Required readiness answer is missing: $path',
            resumeStage: ReadinessStage.draft,
          ),
        );
      }
    }
    if (blockers.isNotEmpty) {
      state = _rebindDigest(state.copyWith(blockers: blockers));
      store.save(state);
      return state;
    }
    if (state.stage == ReadinessStage.draft) {
      state = state.advance(ReadinessStage.answered);
    }

    final fingerprints = Map<String, String>.from(state.secretFingerprints);
    final references = _mergedSecretReferences(state);
    for (final name in _requiredSecretNames) {
      final rawReference = references[name];
      if (rawReference == null || rawReference.isEmpty) {
        blockers.add(
          ReadinessBlocker(
            kind: BlockerKind.missingInput,
            checkId: 'secret.$name',
            message: 'Required credential reference is missing: $name',
            resumeStage: ReadinessStage.answered,
          ),
        );
        continue;
      }
      try {
        final validation = SecretReference.parse(rawReference).validate(
          repositoryRoot: repositoryRoot,
        );
        if (!validation.isValid) {
          blockers.add(
            ReadinessBlocker(
              kind: BlockerKind.security,
              checkId: 'secret.$name',
              message: validation.error!,
              resumeStage: ReadinessStage.answered,
            ),
          );
        } else {
          fingerprints[name] = validation.fingerprint!;
        }
      } on FormatException catch (error) {
        blockers.add(
          ReadinessBlocker(
            kind: BlockerKind.security,
            checkId: 'secret.$name',
            message: error.message,
            resumeStage: ReadinessStage.answered,
          ),
        );
      }
    }

    if (blockers.isNotEmpty || !live) {
      state = _rebindDigest(
        state.copyWith(
          blockers: blockers,
          secretFingerprints: fingerprints,
        ),
      );
      store.save(state);
      return state;
    }

    for (final evidenceName in _requiredEvidence) {
      if (state.evidence[evidenceName] != true) {
        blockers.add(
          ReadinessBlocker(
            kind: BlockerKind.externalResource,
            checkId: 'evidence.$evidenceName',
            message: 'Live provider evidence is missing: $evidenceName',
            resumeStage: ReadinessStage.answered,
          ),
        );
      }
    }
    final githubError = await github.validate();
    if (githubError != null) {
      blockers.add(
        ReadinessBlocker(
          kind: BlockerKind.authentication,
          checkId: 'github.auth',
          message: githubError,
          resumeStage: ReadinessStage.answered,
          remediationUrl: Uri.parse(
            'https://cli.github.com/manual/gh_auth_login',
          ),
        ),
      );
    }
    if (blockers.isEmpty && state.stage == ReadinessStage.answered) {
      state = state.advance(ReadinessStage.resourcesValidated);
    }
    state = _rebindDigest(
      state.copyWith(
        blockers: blockers,
        secretFingerprints: fingerprints,
      ),
    );
    store.save(state);
    return state;
  }

  /// Plans or configures the two protected release environments.
  Future<ReadinessOutcome> configureGithub({required bool confirm}) async {
    var state = status();
    if (state.stage != ReadinessStage.resourcesValidated) {
      throw StateError('Provider resources must validate before GitHub setup');
    }
    final answers = _mergedAnswers(state);
    final internal =
        _readPath(answers, 'github.internalEnvironment')! as String;
    final production =
        _readPath(answers, 'github.productionEnvironment')! as String;
    final effects = confirm ? github : DryRunEffects();
    await effects.createGithubEnvironment(internal);
    await effects.createGithubEnvironment(production);
    final plan = effects is DryRunEffects ? effects.plan : const <String>[];
    if (confirm) {
      final environmentErrors = <String?>[
        await github.validateEnvironment(internal),
        await github.validateEnvironment(production),
      ].whereType<String>().toList(growable: false);
      if (environmentErrors.isNotEmpty) {
        state = state.copyWith(
          blockers: [
            for (final error in environmentErrors)
              ReadinessBlocker(
                kind: BlockerKind.security,
                checkId: 'github.environmentProtection',
                message: error,
                resumeStage: ReadinessStage.resourcesValidated,
              ),
          ],
        );
        store.save(state);
        return ReadinessOutcome(state);
      }
      state = state
          .advance(ReadinessStage.githubConfigured)
          .copyWith(
            blockers: const [],
          );
      store.save(state);
    }
    return ReadinessOutcome(state, plan: plan);
  }

  /// Binds approval and READY to the exact current inputs.
  ReadinessState approve() {
    var state = _refreshDigest(status());
    if (state.stage != ReadinessStage.githubConfigured || !state.isUnblocked) {
      throw StateError('GitHub must be configured and all blockers cleared');
    }
    final digest = _digestForState(state);
    state = state
        .advance(ReadinessStage.approved)
        .copyWith(
          approvedDigest: digest,
          approvedAt: DateTime.now().toUtc(),
        );
    state = state.advance(ReadinessStage.ready);
    store.save(state);
    return state;
  }

  /// Plans or performs a validate-before-switch credential rotation.
  Future<ReadinessOutcome> rotate({
    required String name,
    required String environment,
    required String replacementReference,
    required bool confirm,
  }) async {
    var state = status();
    if (state.stage != ReadinessStage.ready) {
      throw StateError('Credential rotation requires READY state');
    }
    final reference = SecretReference.parse(replacementReference);
    final validation = reference.validate(repositoryRoot: repositoryRoot);
    if (!validation.isValid) {
      throw StateError(
        'Replacement credential failed validation: ${validation.error}',
      );
    }
    final dryRun = DryRunEffects();
    await dryRun.setGithubSecret(environment, name, '[REDACTED]');
    if (!confirm) return ReadinessOutcome(state, plan: dryRun.plan);
    if (reference is! FileSecretReference) {
      throw UnsupportedError(
        'Confirmed keychain rotation requires an interactive keychain adapter',
      );
    }
    final bytes = File(_expandHome(reference.path)).readAsBytesSync();
    final value = base64.encode(bytes);
    await github.setGithubSecret(environment, name, value);
    final fingerprints = Map<String, String>.from(state.secretFingerprints)
      ..[name] = validation.fingerprint!;
    final revocations = Map<String, DateTime>.from(state.pendingRevocations)
      ..[name] = DateTime.now().toUtc().add(const Duration(hours: 24));
    state = _rebindDigest(
      state.copyWith(
        secretFingerprints: fingerprints,
        pendingRevocations: revocations,
      ),
    );
    store.save(state);
    return ReadinessOutcome(state);
  }

  ReadinessState _refreshDigest(ReadinessState state) {
    final digest = _digestForState(state);
    if (state.inputsDigest == digest) return state;
    final refreshed = ReadinessState(
      schemaVersion: state.schemaVersion,
      stage: ReadinessStage.draft,
      inputsDigest: digest,
      answers: state.answers,
      evidence: state.evidence,
      secretFingerprints: const {},
      blockers: const [
        ReadinessBlocker(
          kind: BlockerKind.security,
          checkId: 'inputs.stale',
          message:
              'Readiness inputs changed; validation and approval are stale',
          resumeStage: ReadinessStage.draft,
        ),
      ],
      updatedAt: DateTime.now().toUtc(),
    );
    store.save(refreshed);
    return refreshed;
  }

  ReadinessState _rebindDigest(ReadinessState state) => ReadinessState(
    schemaVersion: state.schemaVersion,
    stage: state.stage,
    inputsDigest: _digestForState(state),
    answers: state.answers,
    evidence: state.evidence,
    secretFingerprints: state.secretFingerprints,
    blockers: state.blockers,
    updatedAt: DateTime.now().toUtc(),
    approvedDigest: state.approvedDigest,
    approvedAt: state.approvedAt,
    pendingRevocations: state.pendingRevocations,
  );

  String _digestForState(ReadinessState? state) {
    final digestManifest = Map<String, Object?>.from(manifest)
      ..['localAnswers'] = state?.answers ?? const <String, Object?>{}
      ..['localEvidence'] = state?.evidence ?? const <String, Object?>{}
      ..['secretFingerprints'] =
          state?.secretFingerprints ?? const <String, String>{};
    return computeInputsDigest(
      starterYaml: _starterFile.readAsStringSync(),
      readinessManifest: digestManifest,
      toolVersion: manifest['toolVersion']! as String,
    );
  }

  Map<String, Object?> _mergedAnswers(ReadinessState state) {
    final base = Map<String, Object?>.from(
      manifest['answers']! as Map<String, Object?>,
    );
    for (final entry in state.answers.entries) {
      if (!entry.key.startsWith('secret.')) {
        _writePath(base, entry.key, entry.value);
      }
    }
    return base;
  }

  Map<String, String> _mergedSecretReferences(ReadinessState state) {
    final base = (manifest['secretReferences']! as Map<String, Object?>).map(
      (key, value) => MapEntry(key, value! as String),
    )..addAll(_loadSecretReferences());
    return base;
  }

  Map<String, String> _loadSecretReferences() {
    if (!referenceFile.existsSync()) return {};
    final byEnvironmentName = <String, String>{};
    for (final line in referenceFile.readAsLinesSync()) {
      final separator = line.indexOf('=');
      if (separator <= 0 || line.trimLeft().startsWith('#')) continue;
      byEnvironmentName[line.substring(0, separator)] = line.substring(
        separator + 1,
      );
    }
    return {
      for (final name in _requiredSecretNames)
        if (byEnvironmentName[_referenceEnvironmentName(name)] != null)
          name: byEnvironmentName[_referenceEnvironmentName(name)]!,
    };
  }

  void _saveSecretReference(String name, String value) {
    final references = _loadSecretReferences()..[name] = value;
    final contents = references.entries
        .map(
          (entry) => '${_referenceEnvironmentName(entry.key)}=${entry.value}',
        )
        .join('\n');
    referenceFile.writeAsStringSync('$contents\n', flush: true);
    if (!Platform.isWindows) {
      final result = Process.runSync('chmod', ['600', referenceFile.path]);
      if (result.exitCode != 0) {
        throw FileSystemException(
          'Unable to restrict release reference file',
          referenceFile.path,
        );
      }
    }
  }

  bool _isMissing(String path, Object? value) {
    if (value == null || value == '' || value is List && value.isEmpty) {
      return true;
    }
    if ((path == 'apple.appRecordCreated' ||
            path == 'googlePlay.appRecordCreated' ||
            path == 'googlePlay.playDeveloperApiEnabled' ||
            path == 'github.oidcTrustConfigured') &&
        value != true) {
      return true;
    }
    return false;
  }
}

Object? _readPath(Map<String, Object?> map, String path) {
  Object? current = map;
  for (final segment in path.split('.')) {
    if (current is! Map<String, Object?>) return null;
    current = current[segment];
  }
  return current;
}

void _writePath(Map<String, Object?> map, String path, Object? value) {
  final segments = path.split('.');
  var current = map;
  for (final segment in segments.take(segments.length - 1)) {
    final next = current[segment];
    if (next is Map<String, Object?>) {
      current = next;
    } else {
      final created = <String, Object?>{};
      current[segment] = created;
      current = created;
    }
  }
  current[segments.last] = value;
}

bool _looksLikeCredential(Object? value) {
  if (value is! String) return false;
  if (value.startsWith('file://') || value.startsWith('keychain://')) {
    return false;
  }
  final normalized = value.toUpperCase();
  return normalized.contains('BEGIN PRIVATE KEY') ||
      normalized.contains('BEGIN CERTIFICATE') ||
      normalized.contains('PRIVATE_KEY');
}

String _expandHome(String value) {
  if (!value.startsWith(r'$HOME/')) return value;
  return '${Platform.environment['HOME']}/${value.substring(r'$HOME/'.length)}';
}

String _referenceEnvironmentName(String value) {
  final buffer = StringBuffer();
  for (var index = 0; index < value.length; index++) {
    final character = value[index];
    if (character.toUpperCase() == character &&
        character.toLowerCase() != character &&
        index > 0) {
      buffer.write('_');
    }
    buffer.write(character.toUpperCase());
  }
  return '${buffer}_REF';
}
