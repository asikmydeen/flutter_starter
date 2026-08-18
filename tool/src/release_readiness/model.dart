/// Ordered readiness phases. A project cannot skip a phase.
enum ReadinessStage {
  draft('DRAFT'),
  answered('ANSWERED'),
  resourcesValidated('RESOURCES_VALIDATED'),
  githubConfigured('GITHUB_CONFIGURED'),
  approved('APPROVED'),
  ready('READY');

  const ReadinessStage(this.wireName);

  /// Stable value persisted in readiness files.
  final String wireName;

  /// Parses a persisted stage.
  static ReadinessStage parse(String value) => values.firstWhere(
    (stage) => stage.wireName == value,
    orElse: () => throw FormatException('Unknown readiness stage: $value'),
  );
}

/// Why readiness is blocked. Blocking is orthogonal to the current phase.
enum BlockerKind {
  missingInput('BLOCKED_INPUT'),
  authentication('BLOCKED_AUTH'),
  externalResource('BLOCKED_EXTERNAL_RESOURCE'),
  security('BLOCKED_SECURITY');

  const BlockerKind(this.wireName);

  /// Stable value persisted in readiness files.
  final String wireName;

  /// Parses a persisted blocker kind.
  static BlockerKind parse(String value) => values.firstWhere(
    (kind) => kind.wireName == value,
    orElse: () => throw FormatException('Unknown blocker kind: $value'),
  );
}

/// A redacted, actionable reason readiness cannot advance.
final class ReadinessBlocker {
  /// Creates a blocker.
  const ReadinessBlocker({
    required this.kind,
    required this.checkId,
    required this.message,
    required this.resumeStage,
    this.remediationUrl,
  });

  /// Blocker category.
  final BlockerKind kind;

  /// Stable machine-readable check identifier.
  final String checkId;

  /// Redacted remediation message.
  final String message;

  /// Phase that should be re-run after remediation.
  final ReadinessStage resumeStage;

  /// Official documentation for the manual action, when available.
  final Uri? remediationUrl;

  /// Serializes this blocker.
  Map<String, Object?> toJson() => {
    'kind': kind.wireName,
    'checkId': checkId,
    'message': message,
    'resumeStage': resumeStage.wireName,
    'remediationUrl': remediationUrl?.toString(),
  };

  /// Parses a blocker.
  // Kept beside serialization so wire-format changes stay reviewable.
  // ignore: sort_constructors_first
  factory ReadinessBlocker.fromJson(Map<String, Object?> json) =>
      ReadinessBlocker(
        kind: BlockerKind.parse(json['kind']! as String),
        checkId: json['checkId']! as String,
        message: json['message']! as String,
        resumeStage: ReadinessStage.parse(json['resumeStage']! as String),
        remediationUrl: switch (json['remediationUrl']) {
          final String value when value.isNotEmpty => Uri.parse(value),
          _ => null,
        },
      );
}

/// Resumable local readiness state. It contains no credential values.
final class ReadinessState {
  /// Creates readiness state.
  const ReadinessState({
    required this.schemaVersion,
    required this.stage,
    required this.inputsDigest,
    required this.answers,
    required this.evidence,
    required this.secretFingerprints,
    required this.blockers,
    required this.updatedAt,
    this.approvedDigest,
    this.approvedAt,
    this.pendingRevocations = const {},
  });

  /// Initial state for a set of inputs.
  factory ReadinessState.initial({required String inputsDigest}) =>
      ReadinessState(
        schemaVersion: 1,
        stage: ReadinessStage.draft,
        inputsDigest: inputsDigest,
        answers: const {},
        evidence: const {},
        secretFingerprints: const {},
        blockers: const [],
        updatedAt: DateTime.now().toUtc(),
      );

  final int schemaVersion;
  final ReadinessStage stage;
  final String inputsDigest;
  final Map<String, Object?> answers;
  final Map<String, Object?> evidence;
  final Map<String, String> secretFingerprints;
  final List<ReadinessBlocker> blockers;
  final DateTime updatedAt;
  final String? approvedDigest;
  final DateTime? approvedAt;

  /// Credential name to required human-revocation deadline.
  final Map<String, DateTime> pendingRevocations;

  /// Whether no blocker is active.
  bool get isUnblocked => blockers.isEmpty;

  /// Advances exactly one phase.
  ReadinessState advance(ReadinessStage next) {
    if (next.index != stage.index + 1) {
      throw StateError(
        'Invalid readiness transition: ${stage.wireName} -> ${next.wireName}',
      );
    }
    return copyWith(stage: next);
  }

  /// Returns updated immutable state.
  ReadinessState copyWith({
    ReadinessStage? stage,
    String? inputsDigest,
    Map<String, Object?>? answers,
    Map<String, Object?>? evidence,
    Map<String, String>? secretFingerprints,
    List<ReadinessBlocker>? blockers,
    DateTime? updatedAt,
    String? approvedDigest,
    DateTime? approvedAt,
    Map<String, DateTime>? pendingRevocations,
  }) => ReadinessState(
    schemaVersion: schemaVersion,
    stage: stage ?? this.stage,
    inputsDigest: inputsDigest ?? this.inputsDigest,
    answers: answers ?? this.answers,
    evidence: evidence ?? this.evidence,
    secretFingerprints: secretFingerprints ?? this.secretFingerprints,
    blockers: blockers ?? this.blockers,
    updatedAt: updatedAt ?? DateTime.now().toUtc(),
    approvedDigest: approvedDigest ?? this.approvedDigest,
    approvedAt: approvedAt ?? this.approvedAt,
    pendingRevocations: pendingRevocations ?? this.pendingRevocations,
  );

  /// Serializes state without secret values.
  Map<String, Object?> toJson() => {
    'schemaVersion': schemaVersion,
    'stage': stage.wireName,
    'inputsDigest': inputsDigest,
    'answers': answers,
    'evidence': evidence,
    'secretFingerprints': secretFingerprints,
    'blockers': blockers.map((blocker) => blocker.toJson()).toList(),
    'updatedAt': updatedAt.toIso8601String(),
    'approvedDigest': approvedDigest,
    'approvedAt': approvedAt?.toIso8601String(),
    'pendingRevocations': pendingRevocations.map(
      (key, value) => MapEntry(key, value.toIso8601String()),
    ),
  };

  /// Parses persisted state.
  // Kept beside serialization so wire-format changes stay reviewable.
  // ignore: sort_constructors_first
  factory ReadinessState.fromJson(Map<String, Object?> json) {
    Map<String, Object?> objectMap(Object? value) =>
        (value! as Map<Object?, Object?>).map(
          (key, item) => MapEntry(key! as String, item),
        );

    return ReadinessState(
      schemaVersion: json['schemaVersion']! as int,
      stage: ReadinessStage.parse(json['stage']! as String),
      inputsDigest: json['inputsDigest']! as String,
      answers: objectMap(json['answers']),
      evidence: objectMap(json['evidence']),
      secretFingerprints: objectMap(json['secretFingerprints']).map(
        (key, value) => MapEntry(key, value! as String),
      ),
      blockers: (json['blockers']! as List<Object?>)
          .map((item) => ReadinessBlocker.fromJson(objectMap(item)))
          .toList(growable: false),
      updatedAt: DateTime.parse(json['updatedAt']! as String),
      approvedDigest: json['approvedDigest'] as String?,
      approvedAt: switch (json['approvedAt']) {
        final String value => DateTime.parse(value),
        _ => null,
      },
      pendingRevocations: objectMap(json['pendingRevocations']).map(
        (key, value) => MapEntry(key, DateTime.parse(value! as String)),
      ),
    );
  }
}
