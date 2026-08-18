import 'package:dio/dio.dart';
import 'package:flutter_starter/core/error/app_exception.dart';
import 'package:flutter_starter/l10n/app_exception_localization.dart';
import 'package:flutter_starter/l10n/gen/app_localizations_en.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:json_annotation/json_annotation.dart';

void main() {
  final l10n = AppLocalizationsEn();

  test('should map network Dio failures', () {
    final request = RequestOptions(path: '/todos');
    for (final type in [
      DioExceptionType.connectionTimeout,
      DioExceptionType.sendTimeout,
      DioExceptionType.receiveTimeout,
      DioExceptionType.connectionError,
    ]) {
      expect(
        mapToAppException(DioException(requestOptions: request, type: type)),
        isA<NetworkException>(),
      );
    }
  });

  test('should map response and parsing failures', () {
    final request = RequestOptions(path: '/todos');
    final responseError = DioException(
      requestOptions: request,
      type: DioExceptionType.badResponse,
      response: Response<dynamic>(requestOptions: request, statusCode: 429),
    );

    final api = mapToAppException(responseError);

    expect(api, isA<ApiException>());
    expect((api as ApiException).statusCode, 429);
    expect(mapToAppException(const FormatException()), isA<ParsingException>());
    expect(mapToAppException(TypeError()), isA<ParsingException>());
    expect(
      mapToAppException(
        CheckedFromJsonException(
          const {},
          'Example',
          'field',
          'bad value',
        ),
      ),
      isA<ParsingException>(),
    );
  });

  test('should pass through typed failures and map unknown failures', () {
    const typed = NetworkException();

    expect(mapToAppException(typed), same(typed));
    expect(mapToAppException(Exception('unexpected')), isA<UnknownException>());
    expect(typed.toString(), 'AppException(network)');
  });

  test('should localize every stable error code', () {
    expect(
      localizeAppException(l10n, const NetworkException()),
      contains('server'),
    );
    expect(
      localizeAppException(l10n, const ApiException(statusCode: 503)),
      contains('503'),
    );
    expect(localizeAppException(l10n, const ParsingException()), isNotEmpty);
    expect(localizeAppException(l10n, const UnknownException()), isNotEmpty);
    expect(
      localizeAppException(l10n, const ConfigurationException()),
      isNotEmpty,
    );
    expect(
      localizeAppException(l10n, const AuthenticationException()),
      isNotEmpty,
    );
    expect(localizeAppException(l10n, const StorageException()), isNotEmpty);
    expect(localizeAppException(l10n, const ConflictException()), isNotEmpty);
  });
}
