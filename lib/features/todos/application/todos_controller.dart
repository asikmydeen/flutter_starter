import 'package:flutter_starter/core/network/dio_client.dart';
import 'package:flutter_starter/core/result/result.dart';
import 'package:flutter_starter/features/todos/data/api_todos_repository.dart';
import 'package:flutter_starter/features/todos/domain/todo.dart';
import 'package:flutter_starter/features/todos/domain/todos_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'todos_controller.g.dart';

/// Binds the [TodosRepository] interface to its HTTP implementation.
/// Tests override this provider with a mock — see
/// `test/features/todos/application/todos_controller_test.dart`.
@riverpod
TodosRepository todosRepository(Ref ref) =>
    ApiTodosRepository(ref.watch(dioProvider));

/// The reference async controller pattern.
///
/// `build` loads the data; [Result] failures are rethrown as the typed
/// `AppException` so Riverpod exposes them as `AsyncError` — the screen
/// renders `error.message` and offers a retry.
@riverpod
class TodosController extends _$TodosController {
  @override
  Future<List<Todo>> build() async {
    final result = await ref.watch(todosRepositoryProvider).fetchTodos();
    return result.valueOrThrow;
  }

  /// Re-fetches the list, moving through loading → data/error.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await ref.read(todosRepositoryProvider).fetchTodos();
      return result.valueOrThrow;
    });
  }
}
