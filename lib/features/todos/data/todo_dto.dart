import 'package:flutter_starter/features/todos/domain/todo.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'todo_dto.freezed.dart';
part 'todo_dto.g.dart';

/// Wire format for a todo as returned by the API.
///
/// DTOs mirror the API exactly and own all JSON concerns. They convert to
/// domain entities via [toDomain] — the rest of the app never sees a DTO.
@freezed
abstract class TodoDto with _$TodoDto {
  /// Creates a DTO from its fields.
  const factory TodoDto({
    required int id,
    required String title,
    required bool completed,
  }) = _TodoDto;

  const TodoDto._();

  /// Parses the API JSON representation.
  factory TodoDto.fromJson(Map<String, dynamic> json) =>
      _$TodoDtoFromJson(json);

  /// Converts this wire model into the domain entity.
  Todo toDomain() => Todo(id: id, title: title, completed: completed);
}
