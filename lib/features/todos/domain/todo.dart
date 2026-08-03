import 'package:freezed_annotation/freezed_annotation.dart';

part 'todo.freezed.dart';

/// Domain entity for a todo item.
///
/// Domain entities are pure: no JSON, no framework imports. Serialization
/// lives on the DTO in the data layer (`data/todo_dto.dart`).
@freezed
abstract class Todo with _$Todo {
  /// Creates a todo.
  const factory Todo({
    required int id,
    required String title,
    required bool completed,
  }) = _Todo;
}
