import 'package:flutter_starter/core/sync/sync_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('should retain durable outbox and conflict values', () {
    final now = DateTime.utc(2026, 8, 17);
    final entry = OutboxEntry(
      idempotencyKey: 'mutation-id',
      entityId: 'todo-id',
      operation: SyncOperation.update,
      baseVersion: 4,
      base: const {'title': 'old'},
      local: const {'title': 'new'},
      createdAt: now,
    );
    const conflict = SyncConflict(
      entityId: 'todo-id',
      base: {'title': 'old'},
      local: {'title': 'local'},
      remote: {'title': 'remote'},
      conflictingFields: {'title'},
    );
    const report = SyncReport(pulled: 2, pushed: 1, conflicts: 1);

    expect(entry.idempotencyKey, 'mutation-id');
    expect(entry.operation, SyncOperation.update);
    expect(entry.baseVersion, 4);
    expect(entry.createdAt, now);
    expect(conflict.conflictingFields, {'title'});
    expect(report.pulled + report.pushed + report.conflicts, 4);
    expect(EntitySyncState.values, hasLength(3));
  });
}
