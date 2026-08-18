import 'package:dio/dio.dart';

import 'package:flutter_starter/core/error/app_exception.dart';
import 'package:flutter_starter/core/result/result.dart';
import 'package:flutter_starter/features/todos/data/todo_dto.dart';
import 'package:flutter_starter/features/todos/domain/todo.dart';
import 'package:flutter_starter/features/todos/domain/todos_repository.dart';

/// HTTP implementation of [TodosRepository].
///
/// The reference data-layer pattern:
///  1. take [Dio] via constructor (injectable → mockable),
///  2. parse into DTOs, convert to domain entities,
///  3. catch everything, map to a typed [AppException], return [Result].
class ApiTodosRepository {
  /// Creates the repository with an injected HTTP client.
  const ApiTodosRepository(this._dio);

  final Dio _dio;

  Future<Result<List<Todo>>> fetchTodos() async {
    try {
      final response = await _dio.get<List<dynamic>>('/todos');
      final data = response.data;
      if (data == null) {
        return const Failure(ParsingException());
      }
      final todos = data
          .map((e) => TodoDto.fromJson(e as Map<String, dynamic>).toDomain())
          .toList();
      return Success(todos);
      // JSON collection casts throw TypeError, which this repository maps.
      // ignore: avoid_catching_errors
    } on TypeError catch (e) {
      return Failure(mapToAppException(e));
    } on Exception catch (e) {
      return Failure(mapToAppException(e));
    }
  }
}
