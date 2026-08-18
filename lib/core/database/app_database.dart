import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_starter/core/sync/sync_models.dart';

part 'app_database.g.dart';

// Drift executes these declarations at build time and generates runtime code.
// coverage:ignore-start
class TodoRecords extends Table {
  TextColumn get userId => text()();
  TextColumn get entityId => text()();
  TextColumn get title => text()();
  BoolColumn get completed => boolean()();
  IntColumn get version => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get syncState => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {userId, entityId};
}

class OutboxRecords extends Table {
  TextColumn get idempotencyKey => text()();
  TextColumn get userId => text()();
  TextColumn get entityId => text()();
  IntColumn get operation => integer()();
  IntColumn get baseVersion => integer()();
  TextColumn get baseJson => text()();
  TextColumn get localJson => text()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {idempotencyKey};
}

class ConflictRecords extends Table {
  TextColumn get userId => text()();
  TextColumn get entityId => text()();
  TextColumn get baseJson => text()();
  TextColumn get localJson => text()();
  TextColumn get remoteJson => text()();
  TextColumn get fieldsJson => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {userId, entityId};
}

class SyncCheckpointRecords extends Table {
  TextColumn get userId => text()();
  TextColumn get collection => text()();
  TextColumn get cursor => text().nullable()();
  DateTimeColumn get synchronizedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {userId, collection};
}
// coverage:ignore-end

@DriftDatabase(
  tables: [
    TodoRecords,
    OutboxRecords,
    ConflictRecords,
    SyncCheckpointRecords,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  factory AppDatabase.defaults() => AppDatabase(
    driftDatabase(name: 'flutter_starter'),
  );

  @override
  int get schemaVersion => 1;

  Stream<List<TodoRecord>> watchVisibleTodos(String user) {
    final query = select(todoRecords)
      ..where((row) => row.userId.equals(user) & row.deletedAt.isNull())
      ..orderBy([(row) => OrderingTerm.desc(row.updatedAt)]);
    return query.watch();
  }

  Future<List<OutboxRecord>> pendingOutbox(String user) {
    final query = select(outboxRecords)
      ..where((row) => row.userId.equals(user))
      ..orderBy([(row) => OrderingTerm.asc(row.createdAt)]);
    return query.get();
  }

  Future<TodoRecord?> todo(String user, String entityId) {
    return (select(todoRecords)..where(
          (row) => row.userId.equals(user) & row.entityId.equals(entityId),
        ))
        .getSingleOrNull();
  }

  Future<void> upsertRemote(TodoRecordsCompanion remote) async {
    final existing = await todo(remote.userId.value, remote.entityId.value);
    if (existing != null && existing.syncState != 0) return;
    await into(todoRecords).insertOnConflictUpdate(remote);
  }

  Future<void> queueTodoMutation({
    required String user,
    required String entityId,
    required String title,
    required bool completed,
    required String idempotencyKey,
    required int operation,
    required DateTime now,
  }) {
    return transaction(() async {
      final existing =
          await (select(todoRecords)..where(
                (row) =>
                    row.userId.equals(user) & row.entityId.equals(entityId),
              ))
              .getSingleOrNull();
      final base = existing == null
          ? const <String, Object?>{}
          : _todoJson(existing);
      final local = <String, Object?>{
        'id': entityId,
        'title': title,
        'completed': completed,
      };
      await into(todoRecords).insertOnConflictUpdate(
        TodoRecordsCompanion.insert(
          userId: user,
          entityId: entityId,
          title: title,
          completed: completed,
          version: Value(existing?.version ?? 0),
          createdAt: existing?.createdAt ?? now,
          updatedAt: now,
          deletedAt: operation == 2 ? Value(now) : const Value.absent(),
          syncState: const Value(1),
        ),
      );
      await into(outboxRecords).insert(
        OutboxRecordsCompanion.insert(
          idempotencyKey: idempotencyKey,
          userId: user,
          entityId: entityId,
          operation: operation,
          baseVersion: existing?.version ?? 0,
          baseJson: jsonEncode(base),
          localJson: jsonEncode(local),
          createdAt: now,
        ),
      );
    });
  }

  Future<void> completeMutation({
    required String idempotencyKey,
    required TodoRecordsCompanion authoritative,
  }) {
    return transaction(() async {
      await into(todoRecords).insertOnConflictUpdate(authoritative);
      await (delete(
        outboxRecords,
      )..where((row) => row.idempotencyKey.equals(idempotencyKey))).go();
    });
  }

  Future<void> rebaseMutation({
    required OutboxRecord current,
    required String newIdempotencyKey,
    required int baseVersion,
    required Map<String, Object?> base,
    required Map<String, Object?> local,
    required String title,
    required bool completed,
    required DateTime now,
  }) {
    return transaction(() async {
      await (delete(outboxRecords)..where(
            (row) => row.idempotencyKey.equals(current.idempotencyKey),
          ))
          .go();
      await into(outboxRecords).insert(
        OutboxRecordsCompanion.insert(
          idempotencyKey: newIdempotencyKey,
          userId: current.userId,
          entityId: current.entityId,
          operation: SyncOperation.update.index,
          baseVersion: baseVersion,
          baseJson: jsonEncode(base),
          localJson: jsonEncode(local),
          attempts: Value(current.attempts + 1),
          createdAt: now,
        ),
      );
      await (update(todoRecords)..where(
            (row) =>
                row.userId.equals(current.userId) &
                row.entityId.equals(current.entityId),
          ))
          .write(
            TodoRecordsCompanion(
              title: Value(title),
              completed: Value(completed),
              version: Value(baseVersion),
              updatedAt: Value(now),
              syncState: const Value(1),
            ),
          );
    });
  }

  Future<void> saveConflict({
    required String user,
    required String entityId,
    required Map<String, Object?> base,
    required Map<String, Object?> local,
    required Map<String, Object?> remote,
    required Set<String> fields,
    required DateTime now,
  }) {
    return transaction(() async {
      await into(conflictRecords).insertOnConflictUpdate(
        ConflictRecordsCompanion.insert(
          userId: user,
          entityId: entityId,
          baseJson: jsonEncode(base),
          localJson: jsonEncode(local),
          remoteJson: jsonEncode(remote),
          fieldsJson: jsonEncode(fields.toList()..sort()),
          createdAt: now,
        ),
      );
      await (update(todoRecords)..where(
            (row) => row.userId.equals(user) & row.entityId.equals(entityId),
          ))
          .write(const TodoRecordsCompanion(syncState: Value(2)));
    });
  }

  Future<void> saveCheckpoint({
    required String user,
    required String collection,
    required String? cursor,
    required DateTime synchronizedAt,
  }) {
    return into(syncCheckpointRecords).insertOnConflictUpdate(
      SyncCheckpointRecordsCompanion.insert(
        userId: user,
        collection: collection,
        cursor: Value(cursor),
        synchronizedAt: Value(synchronizedAt),
      ),
    );
  }

  Future<void> clearUser(String user) {
    return transaction(() async {
      await (delete(
        conflictRecords,
      )..where((row) => row.userId.equals(user))).go();
      await (delete(
        outboxRecords,
      )..where((row) => row.userId.equals(user))).go();
      await (delete(
        syncCheckpointRecords,
      )..where((row) => row.userId.equals(user))).go();
      await (delete(todoRecords)..where((row) => row.userId.equals(user))).go();
    });
  }
}

Map<String, Object?> _todoJson(TodoRecord value) => {
  'id': value.entityId,
  'title': value.title,
  'completed': value.completed,
  'version': value.version,
  'createdAt': value.createdAt.toIso8601String(),
  'updatedAt': value.updatedAt.toIso8601String(),
  'deletedAt': value.deletedAt?.toIso8601String(),
};

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase.defaults();
  ref.onDispose(database.close);
  return database;
});
