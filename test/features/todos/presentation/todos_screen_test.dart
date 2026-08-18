import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_starter/core/error/app_exception.dart';
import 'package:flutter_starter/core/result/result.dart';
import 'package:flutter_starter/core/sync/sync_models.dart';
import 'package:flutter_starter/features/todos/application/todos_controller.dart';
import 'package:flutter_starter/features/todos/domain/todo.dart';
import 'package:flutter_starter/features/todos/domain/todos_repository.dart';
import 'package:flutter_starter/features/todos/presentation/todos_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/helpers.dart';

class MockTodosRepository extends Mock implements TodosRepository {}

void main() {
  final now = DateTime.utc(2026, 8, 17);
  late List<Todo> todos;
  late MockTodosRepository repository;

  setUp(() {
    todos = [
      Todo(
        id: 'todo-1',
        title: 'Write tests',
        completed: false,
        version: 1,
        createdAt: now,
        updatedAt: now,
      ),
      Todo(
        id: 'todo-2',
        title: 'Ship it',
        completed: true,
        version: 1,
        createdAt: now,
        updatedAt: now,
      ),
    ];
    repository = MockTodosRepository();
    when(repository.synchronize).thenAnswer(
      (_) async =>
          const Success(SyncReport(pulled: 0, pushed: 0, conflicts: 0)),
    );
  });

  Future<void> pumpScreen(WidgetTester tester) => tester.pumpApp(
    const TodosScreen(),
    overrides: [todosRepositoryProvider.overrideWithValue(repository)],
  );

  testWidgets('should show loading while waiting for local data', (
    tester,
  ) async {
    final controller = StreamController<Result<List<Todo>>>();
    addTearDown(controller.close);
    when(repository.watchTodos).thenAnswer((_) => controller.stream);

    await pumpScreen(tester);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('should render local Todos', (tester) async {
    when(repository.watchTodos).thenAnswer((_) => Stream.value(Success(todos)));

    await pumpScreen(tester);
    await tester.pumpAndSettle();

    expect(find.text('Write tests'), findsOneWidget);
    expect(find.text('Ship it'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
  });

  testWidgets('should localize typed stream failures', (tester) async {
    when(repository.watchTodos).thenAnswer(
      (_) => Stream.value(const Failure(NetworkException())),
    );

    await pumpScreen(tester);
    await tester.pumpAndSettle();

    expect(
      find.text('Could not reach the server. Check your connection.'),
      findsOneWidget,
    );
  });

  testWidgets('should synchronize when retry is tapped', (tester) async {
    when(repository.watchTodos).thenAnswer(
      (_) => Stream.value(const Failure(NetworkException())),
    );
    await pumpScreen(tester);
    await tester.pumpAndSettle();
    clearInteractions(repository);
    when(repository.synchronize).thenAnswer(
      (_) async =>
          const Success(SyncReport(pulled: 0, pushed: 0, conflicts: 0)),
    );

    await tester.tap(find.text('Retry'));
    await tester.pump();

    verify(repository.synchronize).called(1);
  });
}
