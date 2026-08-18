import 'dart:async';

import 'package:flutter_starter/core/database/app_database.dart';
import 'package:flutter_starter/core/network/dio_client.dart';
import 'package:flutter_starter/core/observability/diagnostic_event.dart';
import 'package:flutter_starter/core/result/result.dart';
import 'package:flutter_starter/features/todos/data/local_first_todos_repository.dart';
import 'package:flutter_starter/features/todos/domain/todo.dart';
import 'package:flutter_starter/features/todos/domain/todos_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'todos_controller.g.dart';

@riverpod
TodosRepository todosRepository(Ref ref) => LocalFirstTodosRepository(
  ref.watch(appDatabaseProvider),
  ref.watch(dioProvider),
  'reference-user',
  diagnostics: ref.watch(diagnosticEventSinkProvider),
);

@riverpod
class TodosController extends _$TodosController {
  @override
  Stream<List<Todo>> build() {
    final repository = ref.watch(todosRepositoryProvider);
    unawaited(repository.synchronize());
    return repository.watchTodos().map((result) => result.valueOrThrow);
  }

  Future<void> refresh() async {
    final result = await ref.read(todosRepositoryProvider).synchronize();
    result.valueOrThrow;
  }

  Future<void> toggle(Todo todo) async {
    final result = await ref
        .read(todosRepositoryProvider)
        .updateTodo(
          todo.copyWith(completed: !todo.completed, updatedAt: DateTime.now()),
        );
    result.valueOrThrow;
  }

  Future<void> delete(Todo todo) async {
    final result = await ref.read(todosRepositoryProvider).deleteTodo(todo);
    result.valueOrThrow;
  }
}
