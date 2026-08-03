import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_starter/core/error/app_exception.dart';
import 'package:flutter_starter/core/result/result.dart';
import 'package:flutter_starter/features/todos/application/todos_controller.dart';
import 'package:flutter_starter/features/todos/domain/todo.dart';
import 'package:flutter_starter/features/todos/domain/todos_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockTodosRepository extends Mock implements TodosRepository {}

/// Reference application-layer test: mock the repository interface with
/// mocktail and drive the controller through a ProviderContainer.
void main() {
  group('TodosController', () {
    late MockTodosRepository repository;
    late ProviderContainer container;

    const todos = [
      Todo(id: 1, title: 'Write tests', completed: false),
      Todo(id: 2, title: 'Ship it', completed: true),
    ];

    setUp(() {
      repository = MockTodosRepository();
      container = ProviderContainer(
        overrides: [todosRepositoryProvider.overrideWithValue(repository)],
        // Riverpod 3 retries failed providers with backoff by default,
        // which makes error-path tests hang. Disable for determinism.
        retry: (_, _) => null,
      );
      addTearDown(container.dispose);
    });

    /// Generated providers are autoDispose: without a listener they are
    /// disposed mid-load. Call this AFTER stubbing the mock — listening
    /// triggers the first build.
    void subscribe() => container.listen(todosControllerProvider, (_, _) {});

    test('should expose todos when the repository succeeds', () async {
      when(
        repository.fetchTodos,
      ).thenAnswer((_) async => const Success(todos));
      subscribe();

      final result = await container.read(todosControllerProvider.future);

      expect(result, todos);
    });

    test('should expose AsyncError when the repository fails', () async {
      when(
        repository.fetchTodos,
      ).thenAnswer((_) async => const Failure(NetworkException()));
      subscribe();

      await expectLater(
        container.read(todosControllerProvider.future),
        throwsA(isA<NetworkException>()),
      );
      expect(
        container.read(todosControllerProvider),
        isA<AsyncError<List<Todo>>>(),
      );
    });

    test(
      'should recover to data when refresh succeeds after a failure',
      () async {
        when(
          repository.fetchTodos,
        ).thenAnswer((_) async => const Failure(NetworkException()));
        subscribe();
        await expectLater(
          container.read(todosControllerProvider.future),
          throwsA(isA<NetworkException>()),
        );

        when(
          repository.fetchTodos,
        ).thenAnswer((_) async => const Success(todos));
        await container.read(todosControllerProvider.notifier).refresh();

        expect(
          container.read(todosControllerProvider),
          isA<AsyncData<List<Todo>>>(),
        );
        expect(container.read(todosControllerProvider).value, todos);
      },
    );
  });
}
