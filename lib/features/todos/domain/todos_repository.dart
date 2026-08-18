import 'package:flutter_starter/core/result/result.dart';
import 'package:flutter_starter/core/sync/sync_models.dart';
import 'package:flutter_starter/features/todos/domain/todo.dart';

/// Local-first Todo contract. Public operations never throw.
abstract interface class TodosRepository {
  Stream<Result<List<Todo>>> watchTodos();

  Future<Result<void>> updateTodo(Todo todo);

  Future<Result<void>> deleteTodo(Todo todo);

  Future<Result<SyncReport>> synchronize();
}
