import 'package:flutter_starter/core/sync/sync_models.dart';
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
    required String id,
    required String title,
    required bool completed,
    required int version,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
    @Default(EntitySyncState.synced) EntitySyncState syncState,
  }) = _Todo;
}
