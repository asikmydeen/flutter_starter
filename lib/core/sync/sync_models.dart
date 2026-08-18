/// Mutation operation persisted in a durable outbox.
enum SyncOperation { create, update, delete }

/// Local synchronization state exposed to domain models.
enum EntitySyncState { synced, pending, conflict }

/// Immutable durable mutation description.
final class OutboxEntry {
  const OutboxEntry({
    required this.idempotencyKey,
    required this.entityId,
    required this.operation,
    required this.baseVersion,
    required this.base,
    required this.local,
    required this.createdAt,
  });

  final String idempotencyKey;
  final String entityId;
  final SyncOperation operation;
  final int baseVersion;
  final Map<String, Object?> base;
  final Map<String, Object?> local;
  final DateTime createdAt;
}

/// Durable values required to resolve an overlapping edit.
final class SyncConflict {
  const SyncConflict({
    required this.entityId,
    required this.base,
    required this.local,
    required this.remote,
    required this.conflictingFields,
  });

  final String entityId;
  final Map<String, Object?> base;
  final Map<String, Object?> local;
  final Map<String, Object?> remote;
  final Set<String> conflictingFields;
}

/// Counts emitted after a synchronization attempt.
final class SyncReport {
  const SyncReport({
    required this.pulled,
    required this.pushed,
    required this.conflicts,
  });

  final int pulled;
  final int pushed;
  final int conflicts;
}
