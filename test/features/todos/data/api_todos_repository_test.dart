import 'package:dio/dio.dart';
import 'package:flutter_starter/core/error/app_exception.dart';
import 'package:flutter_starter/core/result/result.dart';
import 'package:flutter_starter/features/todos/data/api_todos_repository.dart';
import 'package:flutter_starter/features/todos/domain/todo.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

/// Reference data-layer test: mock HTTP at the dio boundary with
/// http_mock_adapter — no real network, no mocking of the repo itself.
void main() {
  group('ApiTodosRepository', () {
    late Dio dio;
    late DioAdapter dioAdapter;
    late ApiTodosRepository repository;

    setUp(() {
      dio = Dio(BaseOptions(baseUrl: 'https://test.example.com'));
      dioAdapter = DioAdapter(dio: dio);
      repository = ApiTodosRepository(dio);
    });

    test(
      'should return Success with todos when the API responds 200',
      () async {
        dioAdapter.onGet(
          '/todos',
          (server) => server.reply(200, [
            {'id': 1, 'title': 'Write tests', 'completed': false},
            {'id': 2, 'title': 'Ship it', 'completed': true},
          ]),
        );

        final result = await repository.fetchTodos();

        expect(result, isA<Success<List<Todo>>>());
        final todos = (result as Success<List<Todo>>).value;
        expect(todos, hasLength(2));
        expect(
          todos.first,
          const Todo(id: 1, title: 'Write tests', completed: false),
        );
      },
    );

    test(
      'should return Failure(ApiException) when the API responds 500',
      () async {
        dioAdapter.onGet(
          '/todos',
          (server) => server.reply(500, {'error': 'boom'}),
        );

        final result = await repository.fetchTodos();

        expect(result, isA<Failure<List<Todo>>>());
        final error = (result as Failure<List<Todo>>).error;
        expect(error, isA<ApiException>());
        expect((error as ApiException).statusCode, 500);
      },
    );

    test(
      'should return Failure(NetworkException) when the connection fails',
      () async {
        dioAdapter.onGet(
          '/todos',
          (server) => server.throws(
            0,
            DioException.connectionError(
              requestOptions: RequestOptions(path: '/todos'),
              reason: 'offline',
            ),
          ),
        );

        final result = await repository.fetchTodos();

        expect(result, isA<Failure<List<Todo>>>());
        expect((result as Failure<List<Todo>>).error, isA<NetworkException>());
      },
    );

    test(
      'should return Failure(ParsingException) when fields are missing',
      () async {
        dioAdapter.onGet(
          '/todos',
          (server) => server.reply(200, [
            {'unexpected': 'shape'},
          ]),
        );

        final result = await repository.fetchTodos();

        expect(result, isA<Failure<List<Todo>>>());
        expect((result as Failure<List<Todo>>).error, isA<ParsingException>());
      },
    );
  });
}
