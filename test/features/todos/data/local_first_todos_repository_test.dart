import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_starter/core/database/app_database.dart';
import 'package:flutter_starter/core/error/app_exception.dart';
import 'package:flutter_starter/core/observability/diagnostic_event.dart';
import 'package:flutter_starter/core/result/result.dart';
import 'package:flutter_starter/core/sync/sync_models.dart';
import 'package:flutter_starter/features/todos/data/local_first_todos_repository.dart';
import 'package:flutter_starter/features/todos/domain/todo.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  final now = DateTime.utc(2026, 8, 17);
  late AppDatabase database;
  late Dio dio;
  late DioAdapter adapter;
  late LocalFirstTodosRepository repository;
  late RecordingDiagnosticSink diagnostics;
  var nextKey = 0;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    dio = Dio(BaseOptions(baseUrl: 'https://api.company.dev'));
    adapter = DioAdapter(dio: dio);
    nextKey = 0;
    diagnostics = RecordingDiagnosticSink();
    repository = LocalFirstTodosRepository(
      database,
      dio,
      'user-1',
      clock: () => now,
      newIdempotencyKey: () => 'key-${nextKey++}',
      newCorrelationId: () => 'correlation-1',
      diagnostics: diagnostics,
    );
    addTearDown(database.close);
  });

  test('should pull remote Todos into the local source of truth', () async {
    adapter.onGet(
      '/v1/todos',
      (server) => server.reply(200, {
        'items': [todoJson(now, title: 'Remote')],
        'nextCursor': 'cursor-1',
      }),
    );

    final result = await repository.synchronize();
    final todos = await repository.watchTodos().firstWhere(
      (value) => value is Success<List<Todo>> && value.value.isNotEmpty,
    );

    expect((result as Success<SyncReport>).value.pulled, 1);
    expect((todos as Success<List<Todo>>).value.single.title, 'Remote');
    expect(diagnostics.events.single.correlationId, 'correlation-1');
    expect(diagnostics.events.single.fields['pulled'], 1);
  });

  test('should queue an offline edit and expose pending state', () async {
    final result = await repository.updateTodo(buildTodo(now, title: 'Local'));
    final visible = await repository.watchTodos().firstWhere(
      (value) => value is Success<List<Todo>> && value.value.isNotEmpty,
    );

    expect(result, isA<Success<void>>());
    expect(
      (visible as Success<List<Todo>>).value.single.syncState,
      EntitySyncState.pending,
    );
    expect(await database.pendingOutbox('user-1'), hasLength(1));
  });

  test('should push a pending edit and drain the outbox', () async {
    await repository.updateTodo(buildTodo(now, title: 'Local'));
    adapter
      ..onGet(
        '/v1/todos',
        (server) => server.reply(200, {
          'items': [todoJson(now, title: 'Remote')],
          'nextCursor': null,
        }),
      )
      ..onPost(
        '/v1/todos/todo-1/mutations',
        (server) => server.reply(
          200,
          todoJson(now, title: 'Authoritative', version: 2),
        ),
        data: {
          'idempotencyKey': 'key-0',
          'baseVersion': 0,
          'operation': 'update',
          'todo': {'id': 'todo-1', 'title': 'Local', 'completed': false},
        },
        headers: {
          'Idempotency-Key': 'key-0',
          'X-Correlation-ID': 'correlation-1',
        },
      );

    final result = await repository.synchronize();

    expect((result as Success<SyncReport>).value.pushed, 1);
    expect(await database.pendingOutbox('user-1'), isEmpty);
    final visible = await repository.watchTodos().first as Success<List<Todo>>;
    expect(visible.value.single.title, 'Authoritative');
  });

  test('should persist overlapping server conflicts', () async {
    await database.upsertRemote(
      TodoRecordsCompanion.insert(
        userId: 'user-1',
        entityId: 'todo-1',
        title: 'Base',
        completed: false,
        version: const Value(1),
        createdAt: now,
        updatedAt: now,
      ),
    );
    await repository.updateTodo(buildTodo(now, title: 'Local'));
    adapter
      ..onGet(
        '/v1/todos',
        (server) => server.reply(200, {
          'items': [todoJson(now, title: 'Remote', version: 2)],
          'nextCursor': null,
        }),
      )
      ..onPost(
        '/v1/todos/todo-1/mutations',
        (server) => server.reply(409, {
          'remote': todoJson(now, title: 'Remote', version: 2),
        }),
        data: {
          'idempotencyKey': 'key-0',
          'baseVersion': 1,
          'operation': 'update',
          'todo': {'id': 'todo-1', 'title': 'Local', 'completed': false},
        },
        headers: {
          'Idempotency-Key': 'key-0',
          'X-Correlation-ID': 'correlation-1',
        },
      );

    final result = await repository.synchronize();

    expect((result as Success<SyncReport>).value.conflicts, 1);
    expect(await database.select(database.conflictRecords).get(), hasLength(1));
    expect((await database.todo('user-1', 'todo-1'))?.syncState, 2);
  });

  test('should rebase disjoint edits and retry once', () async {
    await database.upsertRemote(
      TodoRecordsCompanion.insert(
        userId: 'user-1',
        entityId: 'todo-1',
        title: 'Base',
        completed: false,
        version: const Value(1),
        createdAt: now,
        updatedAt: now,
      ),
    );
    await repository.updateTodo(buildTodo(now, title: 'Local'));
    adapter
      ..onGet(
        '/v1/todos',
        (server) => server.reply(200, {
          'items': [
            {...todoJson(now, title: 'Base', version: 2), 'completed': true},
          ],
          'nextCursor': null,
        }),
      )
      ..onPost(
        '/v1/todos/todo-1/mutations',
        (server) => server.reply(409, {
          'remote': {
            ...todoJson(now, title: 'Base', version: 2),
            'completed': true,
          },
        }),
        data: {
          'idempotencyKey': 'key-0',
          'baseVersion': 1,
          'operation': 'update',
          'todo': {'id': 'todo-1', 'title': 'Local', 'completed': false},
        },
        headers: {
          'Idempotency-Key': 'key-0',
          'X-Correlation-ID': 'correlation-1',
        },
      )
      ..onPost(
        '/v1/todos/todo-1/mutations',
        (server) => server.reply(200, {
          ...todoJson(now, title: 'Local', version: 3),
          'completed': true,
        }),
        data: {
          'idempotencyKey': 'key-1',
          'baseVersion': 2,
          'operation': 'update',
          'todo': {'id': 'todo-1', 'title': 'Local', 'completed': true},
        },
        headers: {
          'Idempotency-Key': 'key-1',
          'X-Correlation-ID': 'correlation-1',
        },
      );

    final result = await repository.synchronize();

    expect((result as Success<SyncReport>).value.pushed, 1);
    expect(result.value.conflicts, 0);
    expect(await database.pendingOutbox('user-1'), isEmpty);
    final todo = await database.todo('user-1', 'todo-1');
    expect(todo?.title, 'Local');
    expect(todo?.completed, isTrue);
    expect(todo?.version, 3);
  });

  test('should map malformed pull payloads to ParsingException', () async {
    adapter.onGet(
      '/v1/todos',
      (server) => server.reply(200, {'items': 'not-a-list'}),
    );

    final result = await repository.synchronize();

    expect(result, isA<Failure<SyncReport>>());
    expect((result as Failure<SyncReport>).error, isA<ParsingException>());
  });

  test('should preserve queued writes when the network fails', () async {
    await repository.updateTodo(buildTodo(now, title: 'Local'));
    adapter.onGet(
      '/v1/todos',
      (server) => server.throws(
        0,
        DioException.connectionError(
          requestOptions: RequestOptions(path: '/v1/todos'),
          reason: 'offline',
        ),
      ),
    );

    final result = await repository.synchronize();

    expect(result, isA<Failure<SyncReport>>());
    expect(await database.pendingOutbox('user-1'), hasLength(1));
  });

  test(
    'should expose local database stream failures as StorageException',
    () async {
      final failingDatabase = FailingAppDatabase();
      addTearDown(failingDatabase.close);
      final failingRepository = LocalFirstTodosRepository(
        failingDatabase,
        dio,
        'user-1',
      );

      final result = await failingRepository.watchTodos().first;

      expect(result, isA<Failure<List<Todo>>>());
      expect((result as Failure<List<Todo>>).error, isA<StorageException>());
    },
  );
}

final class RecordingDiagnosticSink implements DiagnosticEventSink {
  final List<DiagnosticEvent> events = [];

  @override
  Future<void> record(DiagnosticEvent event) async => events.add(event);

  @override
  Future<void> flush() async {}
}

Todo buildTodo(DateTime now, {required String title}) => Todo(
  id: 'todo-1',
  title: title,
  completed: false,
  version: 1,
  createdAt: now,
  updatedAt: now,
);

Map<String, Object?> todoJson(
  DateTime now, {
  required String title,
  int version = 1,
}) => {
  'id': 'todo-1',
  'title': title,
  'completed': false,
  'version': version,
  'createdAt': now.toIso8601String(),
  'updatedAt': now.toIso8601String(),
  'deletedAt': null,
};

final class FailingAppDatabase extends AppDatabase {
  FailingAppDatabase() : super(NativeDatabase.memory());

  @override
  Stream<List<TodoRecord>> watchVisibleTodos(String user) =>
      Stream.error(StateError('database failed'));
}
