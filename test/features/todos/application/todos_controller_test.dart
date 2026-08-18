import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_starter/core/error/app_exception.dart';
import 'package:flutter_starter/core/result/result.dart';
import 'package:flutter_starter/core/sync/sync_models.dart';
import 'package:flutter_starter/features/todos/application/todos_controller.dart';
import 'package:flutter_starter/features/todos/domain/todo.dart';
import 'package:flutter_starter/features/todos/domain/todos_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockTodosRepository extends Mock implements TodosRepository {}

void main() {
  final now = DateTime.utc(2026, 8, 17);
  late List<Todo> todos;
  late MockTodosRepository repository;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(
      Todo(
        id: 'fallback',
        title: 'fallback',
        completed: false,
        version: 0,
        createdAt: now,
        updatedAt: now,
      ),
    );
  });

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
    ];
    repository = MockTodosRepository();
    when(repository.synchronize).thenAnswer(
      (_) async =>
          const Success(SyncReport(pulled: 0, pushed: 0, conflicts: 0)),
    );
    container = ProviderContainer(
      overrides: [todosRepositoryProvider.overrideWithValue(repository)],
      retry: (_, _) => null,
    );
    addTearDown(container.dispose);
  });

  void subscribe() => container.listen(todosControllerProvider, (_, _) {});

  test('should expose local Todos from the repository stream', () async {
    when(repository.watchTodos).thenAnswer(
      (_) => Stream.value(Success(todos)),
    );
    subscribe();

    expect(await container.read(todosControllerProvider.future), todos);
  });

  test('should expose typed stream failures as AsyncError', () async {
    when(repository.watchTodos).thenAnswer(
      (_) => Stream.value(const Failure(NetworkException())),
    );
    subscribe();

    await expectLater(
      container.read(todosControllerProvider.future),
      throwsA(isA<NetworkException>()),
    );
  });

  test('should synchronize on refresh', () async {
    when(repository.watchTodos).thenAnswer(
      (_) => Stream.value(Success(todos)),
    );
    subscribe();
    await container.read(todosControllerProvider.future);

    await container.read(todosControllerProvider.notifier).refresh();

    verify(repository.synchronize).called(greaterThanOrEqualTo(2));
  });

  test('should queue toggles and deletes through the repository', () async {
    when(repository.watchTodos).thenAnswer(
      (_) => Stream.value(Success(todos)),
    );
    when(() => repository.updateTodo(any())).thenAnswer(
      (_) async => const Success(null),
    );
    when(() => repository.deleteTodo(any())).thenAnswer(
      (_) async => const Success(null),
    );
    subscribe();
    await container.read(todosControllerProvider.future);
    final controller = container.read(todosControllerProvider.notifier);

    await controller.toggle(todos.single);
    await controller.delete(todos.single);

    final updated = verify(() => repository.updateTodo(captureAny())).captured;
    expect((updated.single as Todo).completed, isTrue);
    verify(() => repository.deleteTodo(todos.single)).called(1);
  });
}
