import 'package:flutter/material.dart';
import 'package:flutter_starter/core/error/app_exception.dart';
import 'package:flutter_starter/core/result/result.dart';
import 'package:flutter_starter/features/todos/application/todos_controller.dart';
import 'package:flutter_starter/features/todos/domain/todo.dart';
import 'package:flutter_starter/features/todos/domain/todos_repository.dart';
import 'package:flutter_starter/features/todos/presentation/todos_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/helpers.dart';

class MockTodosRepository extends Mock implements TodosRepository {}

/// Reference widget test: pump the screen with the repository provider
/// overridden — the full provider graph above it runs for real.
void main() {
  late MockTodosRepository repository;

  const todos = [
    Todo(id: 1, title: 'Write tests', completed: false),
    Todo(id: 2, title: 'Ship it', completed: true),
  ];

  setUp(() {
    repository = MockTodosRepository();
  });

  Future<void> pumpScreen(WidgetTester tester) {
    return tester.pumpApp(
      const TodosScreen(),
      overrides: [todosRepositoryProvider.overrideWithValue(repository)],
    );
  }

  group('TodosScreen', () {
    testWidgets('should show a loading indicator while fetching', (
      tester,
    ) async {
      when(repository.fetchTodos).thenAnswer((_) async => const Success(todos));

      await pumpScreen(tester);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('should render the todo list when fetching succeeds', (
      tester,
    ) async {
      when(repository.fetchTodos).thenAnswer((_) async => const Success(todos));

      await pumpScreen(tester);
      await tester.pumpAndSettle();

      expect(find.text('Write tests'), findsOneWidget);
      expect(find.text('Ship it'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('should show the error message and retry when fetching fails', (
      tester,
    ) async {
      when(
        repository.fetchTodos,
      ).thenAnswer((_) async => const Failure(NetworkException()));

      await pumpScreen(tester);
      await tester.pumpAndSettle();

      expect(find.text(const NetworkException().message), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('should reload data when retry is tapped', (tester) async {
      when(
        repository.fetchTodos,
      ).thenAnswer((_) async => const Failure(NetworkException()));
      await pumpScreen(tester);
      await tester.pumpAndSettle();

      when(repository.fetchTodos).thenAnswer((_) async => const Success(todos));
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(find.text('Write tests'), findsOneWidget);
    });
  });
}
