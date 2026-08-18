@Tags(['integration'])
library;

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_starter/core/database/app_database.dart';
import 'package:flutter_starter/core/result/result.dart';
import 'package:flutter_starter/core/sync/sync_models.dart';
import 'package:flutter_starter/features/todos/application/todos_controller.dart';
import 'package:flutter_starter/features/todos/data/local_first_todos_repository.dart';
import 'package:flutter_starter/features/todos/domain/todo.dart';
import 'package:flutter_starter/features/todos/domain/todos_repository.dart';
import 'package:flutter_starter/features/todos/presentation/todos_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

import '../helpers/helpers.dart';

void main() {
  test(
    'should pull data and preserve an offline edit after database restart',
    () async {
      final directory = Directory.systemTemp.createTempSync(
        'walking_skeleton_',
      );
      addTearDown(() => directory.deleteSync(recursive: true));
      final file = File('${directory.path}/app.sqlite');
      final database = AppDatabase(NativeDatabase(file));
      final dio = Dio(BaseOptions(baseUrl: 'https://api.company.dev'));
      DioAdapter(dio: dio).onGet(
        '/v1/todos',
        (server) => server.reply(200, {
          'items': [_todoJson],
          'nextCursor': null,
        }),
      );
      var key = 0;
      final repository = LocalFirstTodosRepository(
        database,
        dio,
        'user-1',
        newIdempotencyKey: () => 'mutation-${key++}',
      );

      expect(await repository.synchronize(), isA<Success<SyncReport>>());
      final local = (await repository.watchTodos().first as Success<List<Todo>>)
          .value
          .single;
      expect(
        await repository.updateTodo(local.copyWith(title: 'Offline edit')),
        isA<Success<void>>(),
      );
      await database.close();

      final reopened = AppDatabase(NativeDatabase(file));
      addTearDown(reopened.close);
      expect(await reopened.pendingOutbox('user-1'), hasLength(1));
      expect(
        (await reopened.watchVisibleTodos('user-1').first).single.title,
        'Offline edit',
      );
    },
  );

  testWidgets('should render synchronized local data', (tester) async {
    final repository = SnapshotTodosRepository(
      Todo(
        id: 'todo-1',
        title: 'Walking skeleton',
        completed: false,
        version: 1,
        createdAt: DateTime.utc(2026, 8, 17),
        updatedAt: DateTime.utc(2026, 8, 17),
      ),
    );

    await tester.pumpApp(
      const TodosScreen(),
      overrides: [todosRepositoryProvider.overrideWithValue(repository)],
    );
    await tester.pumpAndSettle();

    expect(find.text('Walking skeleton'), findsOneWidget);
  });
}

const Map<String, Object?> _todoJson = {
  'id': 'todo-1',
  'title': 'Walking skeleton',
  'completed': false,
  'version': 1,
  'createdAt': '2026-08-17T00:00:00.000Z',
  'updatedAt': '2026-08-17T00:00:00.000Z',
  'deletedAt': null,
};

final class SnapshotTodosRepository implements TodosRepository {
  const SnapshotTodosRepository(this.todo);

  final Todo todo;

  @override
  Future<Result<void>> deleteTodo(Todo todo) async => const Success(null);

  @override
  Future<Result<SyncReport>> synchronize() async =>
      const Success(SyncReport(pulled: 0, pushed: 0, conflicts: 0));

  @override
  Future<Result<void>> updateTodo(Todo todo) async => const Success(null);

  @override
  Stream<Result<List<Todo>>> watchTodos() => Stream.value(Success([todo]));
}
