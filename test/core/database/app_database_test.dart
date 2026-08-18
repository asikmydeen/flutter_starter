import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_starter/core/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;

  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);
  tearDownAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = false);

  setUp(() => database = AppDatabase(NativeDatabase.memory()));
  tearDown(() => database.close());

  test('should commit a local Todo and outbox entry atomically', () async {
    final now = DateTime.utc(2026, 8, 17);

    await database.queueTodoMutation(
      user: 'user-1',
      entityId: 'todo-1',
      title: 'Offline edit',
      completed: false,
      idempotencyKey: 'mutation-1',
      operation: 1,
      now: now,
    );

    final todos = await database.watchVisibleTodos('user-1').first;
    final outbox = await database.pendingOutbox('user-1');
    expect(todos.single.title, 'Offline edit');
    expect(todos.single.syncState, 1);
    expect(outbox.single.idempotencyKey, 'mutation-1');
    expect(outbox.single.baseVersion, 0);
  });

  test('should retain the server base when editing an existing Todo', () async {
    final now = DateTime.utc(2026, 8, 17);
    await database.upsertRemote(
      TodoRecordsCompanion.insert(
        userId: 'user-1',
        entityId: 'todo-1',
        title: 'Server base',
        completed: false,
        version: const Value(7),
        createdAt: now,
        updatedAt: now,
      ),
    );

    await database.queueTodoMutation(
      user: 'user-1',
      entityId: 'todo-1',
      title: 'Local edit',
      completed: true,
      idempotencyKey: 'mutation-1',
      operation: 1,
      now: now.add(const Duration(seconds: 1)),
    );

    final outbox = (await database.pendingOutbox('user-1')).single;
    expect(outbox.baseVersion, 7);
    expect(outbox.baseJson, contains('Server base'));
  });

  test('should complete a mutation and drain its outbox entry', () async {
    final now = DateTime.utc(2026, 8, 17);
    await database.queueTodoMutation(
      user: 'user-1',
      entityId: 'todo-1',
      title: 'Local',
      completed: false,
      idempotencyKey: 'mutation-1',
      operation: 1,
      now: now,
    );

    await database.completeMutation(
      idempotencyKey: 'mutation-1',
      authoritative: TodoRecordsCompanion.insert(
        userId: 'user-1',
        entityId: 'todo-1',
        title: 'Server',
        completed: true,
        version: const Value(2),
        createdAt: now,
        updatedAt: now.add(const Duration(seconds: 1)),
        syncState: const Value(0),
      ),
    );

    expect(await database.pendingOutbox('user-1'), isEmpty);
    final todo = (await database.watchVisibleTodos('user-1').first).single;
    expect(todo.title, 'Server');
    expect(todo.completed, isTrue);
    expect(todo.version, 2);
    expect(todo.syncState, 0);
  });

  test('should persist exact conflict values and mark the Todo', () async {
    final now = DateTime.utc(2026, 8, 17);
    await database.queueTodoMutation(
      user: 'user-1',
      entityId: 'todo-1',
      title: 'Local',
      completed: false,
      idempotencyKey: 'mutation-1',
      operation: 1,
      now: now,
    );

    await database.saveConflict(
      user: 'user-1',
      entityId: 'todo-1',
      base: const {'title': 'Base'},
      local: const {'title': 'Local'},
      remote: const {'title': 'Remote'},
      fields: const {'title'},
      now: now,
    );

    final conflicts = await database.select(database.conflictRecords).get();
    expect(conflicts.single.localJson, contains('Local'));
    expect(conflicts.single.remoteJson, contains('Remote'));
    expect(
      (await database.watchVisibleTodos('user-1').first).single.syncState,
      2,
    );
  });

  test('should isolate and clear all records for one user', () async {
    final now = DateTime.utc(2026, 8, 17);
    for (final user in ['user-1', 'user-2']) {
      await database.queueTodoMutation(
        user: user,
        entityId: 'todo-1',
        title: user,
        completed: false,
        idempotencyKey: 'mutation-$user',
        operation: 1,
        now: now,
      );
      await database.saveCheckpoint(
        user: user,
        collection: 'todos',
        cursor: 'cursor-$user',
        synchronizedAt: now,
      );
    }

    await database.clearUser('user-1');

    expect(await database.watchVisibleTodos('user-1').first, isEmpty);
    expect(await database.pendingOutbox('user-1'), isEmpty);
    expect(await database.watchVisibleTodos('user-2').first, hasLength(1));
  });

  test('should retain pending mutations after database restart', () async {
    final directory = Directory.systemTemp.createTempSync('drift_restart_');
    addTearDown(() => directory.deleteSync(recursive: true));
    final file = File('${directory.path}/app.sqlite');
    final first = AppDatabase(NativeDatabase(file));
    final now = DateTime.utc(2026, 8, 17);
    await first.queueTodoMutation(
      user: 'user-1',
      entityId: 'todo-1',
      title: 'Survives restart',
      completed: false,
      idempotencyKey: 'mutation-1',
      operation: 1,
      now: now,
    );
    await first.close();

    final reopened = AppDatabase(NativeDatabase(file));
    addTearDown(reopened.close);

    expect(await reopened.pendingOutbox('user-1'), hasLength(1));
    expect(
      (await reopened.watchVisibleTodos('user-1').first).single.title,
      'Survives restart',
    );
  });
}
