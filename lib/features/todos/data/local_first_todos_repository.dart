import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:flutter_starter/core/database/app_database.dart';
import 'package:flutter_starter/core/error/app_exception.dart';
import 'package:flutter_starter/core/observability/diagnostic_event.dart';
import 'package:flutter_starter/core/result/result.dart';
import 'package:flutter_starter/core/sync/sync_models.dart';
import 'package:flutter_starter/core/sync/three_way_merge.dart';
import 'package:flutter_starter/features/todos/data/todo_dto.dart';
import 'package:flutter_starter/features/todos/domain/todo.dart';
import 'package:flutter_starter/features/todos/domain/todos_repository.dart';
import 'package:uuid/uuid.dart';

class LocalFirstTodosRepository implements TodosRepository {
  LocalFirstTodosRepository(
    this._database,
    this._dio,
    this._userId, {
    DateTime Function()? clock,
    String Function()? newIdempotencyKey,
    String Function()? newCorrelationId,
    DiagnosticEventSink? diagnostics,
  }) : _clock = clock ?? DateTime.now,
       _newIdempotencyKey = newIdempotencyKey ?? const Uuid().v4,
       _newCorrelationId = newCorrelationId ?? const Uuid().v4,
       _diagnostics = diagnostics ?? const NoopDiagnosticEventSink();

  final AppDatabase _database;
  final Dio _dio;
  final String _userId;
  final DateTime Function() _clock;
  final String Function() _newIdempotencyKey;
  final String Function() _newCorrelationId;
  final DiagnosticEventSink _diagnostics;

  @override
  Stream<Result<List<Todo>>> watchTodos() {
    return _database
        .watchVisibleTodos(_userId)
        .transform(
          StreamTransformer.fromHandlers(
            handleData: (rows, sink) => sink.add(
              Success(rows.map(_toDomain).toList(growable: false)),
            ),
            handleError: (error, stack, sink) => sink.add(
              Failure<List<Todo>>(StorageException(cause: error)),
            ),
          ),
        );
  }

  @override
  Future<Result<void>> updateTodo(Todo todo) async {
    try {
      await _database.queueTodoMutation(
        user: _userId,
        entityId: todo.id,
        title: todo.title,
        completed: todo.completed,
        idempotencyKey: _newIdempotencyKey(),
        operation: SyncOperation.update.index,
        now: _clock(),
      );
      return const Success(null);
    } on Exception catch (error) {
      return Failure(StorageException(cause: error));
    }
  }

  @override
  Future<Result<void>> deleteTodo(Todo todo) async {
    try {
      await _database.queueTodoMutation(
        user: _userId,
        entityId: todo.id,
        title: todo.title,
        completed: todo.completed,
        idempotencyKey: _newIdempotencyKey(),
        operation: SyncOperation.delete.index,
        now: _clock(),
      );
      return const Success(null);
    } on Exception catch (error) {
      return Failure(StorageException(cause: error));
    }
  }

  @override
  Future<Result<SyncReport>> synchronize() async {
    try {
      var pulled = 0;
      var pushed = 0;
      var conflicts = 0;
      final correlationId = _newCorrelationId();
      final startedAt = _clock();
      final response = await _dio.get<Map<String, dynamic>>(
        '/v1/todos',
        options: Options(headers: {'X-Correlation-ID': correlationId}),
      );
      final items = response.data?['items'];
      if (items is! List<dynamic>) throw const FormatException('Missing items');
      for (final item in items) {
        final dto = TodoDto.fromJson(item as Map<String, dynamic>);
        await _database.upsertRemote(_remoteCompanion(dto));
        pulled++;
      }

      final pending = await _database.pendingOutbox(_userId);
      for (final entry in pending) {
        final result = await _push(entry, correlationId);
        if (result == _PushResult.pushed) pushed++;
        if (result == _PushResult.conflict) conflicts++;
      }
      await _database.saveCheckpoint(
        user: _userId,
        collection: 'todos',
        cursor: response.data?['nextCursor'] as String?,
        synchronizedAt: _clock(),
      );
      await _diagnostics.record(
        DiagnosticEvent(
          name: 'todos_sync_completed',
          correlationId: correlationId,
          fields: {
            'pulled': pulled,
            'pushed': pushed,
            'conflicts': conflicts,
            'durationMs': _clock().difference(startedAt).inMilliseconds,
          },
        ),
      );
      return Success(
        SyncReport(pulled: pulled, pushed: pushed, conflicts: conflicts),
      );
      // JSON collection casts throw TypeError, which this repository maps.
      // ignore: avoid_catching_errors
    } on TypeError catch (error) {
      return Failure(mapToAppException(error));
    } on Exception catch (error) {
      return Failure(mapToAppException(error));
    }
  }

  Future<_PushResult> _push(
    OutboxRecord entry,
    String correlationId,
  ) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/v1/todos/${entry.entityId}/mutations',
        data: {
          'idempotencyKey': entry.idempotencyKey,
          'baseVersion': entry.baseVersion,
          'operation': SyncOperation.values[entry.operation].name,
          'todo': jsonDecode(entry.localJson),
        },
        options: Options(
          headers: {
            'Idempotency-Key': entry.idempotencyKey,
            'X-Correlation-ID': correlationId,
          },
        ),
      );
      final dto = TodoDto.fromJson(response.data!);
      await _database.completeMutation(
        idempotencyKey: entry.idempotencyKey,
        authoritative: _remoteCompanion(dto),
      );
      return _PushResult.pushed;
    } on DioException catch (error) {
      if (error.response?.statusCode != 409) rethrow;
      final body = error.response?.data;
      if (body is! Map<String, dynamic> ||
          body['remote'] is! Map<String, dynamic>) {
        throw const FormatException('Invalid conflict response');
      }
      final remote = TodoDto.fromJson(
        body['remote']! as Map<String, dynamic>,
      );
      final base = jsonDecode(entry.baseJson)! as Map<String, dynamic>;
      final local = jsonDecode(entry.localJson)! as Map<String, dynamic>;
      final remoteJson = remote.toJson();
      final merge = mergeFields(
        base: _mutableFields(base),
        local: _mutableFields(local),
        remote: _mutableFields(remoteJson),
      );
      if (merge is ConflictingFields) {
        await _database.saveConflict(
          user: _userId,
          entityId: entry.entityId,
          base: base,
          local: local,
          remote: remoteJson,
          fields: merge.fields,
          now: _clock(),
        );
        return _PushResult.conflict;
      }
      if (entry.attempts >= 1) {
        await _database.saveConflict(
          user: _userId,
          entityId: entry.entityId,
          base: base,
          local: local,
          remote: remoteJson,
          fields: const {'title', 'completed'},
          now: _clock(),
        );
        return _PushResult.conflict;
      }
      final merged = (merge as MergedFields).value;
      final newKey = _newIdempotencyKey();
      await _database.rebaseMutation(
        current: entry,
        newIdempotencyKey: newKey,
        baseVersion: remote.version,
        base: remoteJson,
        local: {'id': entry.entityId, ...merged},
        title: merged['title']! as String,
        completed: merged['completed']! as bool,
        now: _clock(),
      );
      final rebased = (await _database.pendingOutbox(_userId)).firstWhere(
        (candidate) => candidate.idempotencyKey == newKey,
      );
      return _push(rebased, correlationId);
    }
  }

  Todo _toDomain(TodoRecord row) => Todo(
    id: row.entityId,
    title: row.title,
    completed: row.completed,
    version: row.version,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
    deletedAt: row.deletedAt,
    syncState: EntitySyncState.values[row.syncState],
  );

  TodoRecordsCompanion _remoteCompanion(TodoDto dto) =>
      TodoRecordsCompanion.insert(
        userId: _userId,
        entityId: dto.id,
        title: dto.title,
        completed: dto.completed,
        version: Value(dto.version),
        createdAt: dto.createdAt,
        updatedAt: dto.updatedAt,
        deletedAt: Value(dto.deletedAt),
      );
}

enum _PushResult { pushed, conflict }

Map<String, Object?> _mutableFields(Map<String, Object?> value) => {
  'title': value['title'],
  'completed': value['completed'],
};
