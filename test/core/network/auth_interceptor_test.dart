import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_starter/core/auth/auth_token_provider.dart';
import 'package:flutter_starter/core/network/auth_interceptor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('should attach the SDK token without persisting it', () async {
    final tokens = _FakeAuthTokenProvider(tokens: ['initial-token']);
    final adapter = _SequenceAdapter([200]);
    final dio = Dio()..httpClientAdapter = adapter;
    dio.interceptors.add(AuthInterceptor(dio, tokens));

    await dio.get<dynamic>('https://api.company.dev/todos');

    expect(
      adapter.requests.single.headers['Authorization'],
      'Bearer initial-token',
    );
    expect(tokens.forceRefreshCalls, 0);
  });

  test(
    'should force refresh once and retry a safe request after 401',
    () async {
      final tokens = _FakeAuthTokenProvider(
        tokens: ['expired-token', 'refreshed-token', 'refreshed-token'],
      );
      final adapter = _SequenceAdapter([401, 200]);
      final dio = Dio()..httpClientAdapter = adapter;
      dio.interceptors.add(AuthInterceptor(dio, tokens));

      final response = await dio.get<dynamic>('https://api.company.dev/todos');

      expect(response.statusCode, 200);
      expect(adapter.requests, hasLength(2));
      expect(
        adapter.requests.last.headers['Authorization'],
        'Bearer refreshed-token',
      );
      expect(tokens.forceRefreshCalls, 1);
      expect(tokens.signOutCalls, 0);
    },
  );

  test('should sign out without retrying an unsafe mutation', () async {
    final tokens = _FakeAuthTokenProvider(tokens: ['expired-token']);
    final adapter = _SequenceAdapter([401]);
    final dio = Dio()..httpClientAdapter = adapter;
    dio.interceptors.add(AuthInterceptor(dio, tokens));

    await expectLater(
      dio.post<dynamic>('https://api.company.dev/todos', data: {'title': 'x'}),
      throwsA(isA<DioException>()),
    );

    expect(adapter.requests, hasLength(1));
    expect(tokens.forceRefreshCalls, 0);
    expect(tokens.signOutCalls, 1);
  });

  test(
    'should retry an idempotent mutation and sign out on second 401',
    () async {
      final tokens = _FakeAuthTokenProvider(
        tokens: ['expired-token', 'refreshed-token', 'refreshed-token'],
      );
      final adapter = _SequenceAdapter([401, 401]);
      final dio = Dio()..httpClientAdapter = adapter;
      dio.interceptors.add(AuthInterceptor(dio, tokens));

      await expectLater(
        dio.post<dynamic>(
          'https://api.company.dev/todos',
          data: {'title': 'x'},
          options: Options(headers: {'Idempotency-Key': 'mutation-id'}),
        ),
        throwsA(isA<DioException>()),
      );

      expect(adapter.requests, hasLength(2));
      expect(tokens.forceRefreshCalls, 1);
      expect(tokens.signOutCalls, 1);
    },
  );
}

final class _FakeAuthTokenProvider implements AuthTokenProvider {
  _FakeAuthTokenProvider({required List<String?> tokens})
    : _tokens = List.of(tokens);

  final List<String?> _tokens;
  int forceRefreshCalls = 0;
  int signOutCalls = 0;

  @override
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    if (forceRefresh) forceRefreshCalls++;
    return _tokens.isEmpty ? null : _tokens.removeAt(0);
  }

  @override
  Future<void> signOut() async => signOutCalls++;
}

final class _SequenceAdapter implements HttpClientAdapter {
  _SequenceAdapter(this._statuses);

  final List<int> _statuses;
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options.copyWith(headers: Map.of(options.headers)));
    final status = _statuses.removeAt(0);
    return ResponseBody.fromString(
      '{}',
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
