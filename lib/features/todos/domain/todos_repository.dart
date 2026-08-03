import 'package:flutter_starter/core/result/result.dart';
import 'package:flutter_starter/features/todos/domain/todo.dart';

/// Contract for fetching todos.
///
/// Defined in the domain layer so the application layer depends on the
/// interface, not on dio. The implementation lives in
/// `data/api_todos_repository.dart`; tests substitute a mock.
// ignore: one_member_abstracts - grows with the feature; interface is the point.
abstract interface class TodosRepository {
  /// Fetches all todos. Never throws — failures come back as [Failure].
  Future<Result<List<Todo>>> fetchTodos();
}
