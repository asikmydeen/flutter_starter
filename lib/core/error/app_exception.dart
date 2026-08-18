import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';

/// The closed set of failures the data layer can produce.
///
/// Every repository maps raw exceptions (Dio errors, format errors, ...)
/// into one of these before returning a `Failure`. UI code only ever deals
/// with [AppException] — never with transport-level exceptions.
sealed class AppException implements Exception {
  const AppException(this.code, {this.cause});

  /// Stable presentation-agnostic identity used for localization.
  final AppExceptionCode code;

  /// The original exception, kept for logs — never shown to users.
  final Object? cause;

  @override
  String toString() => 'AppException(${code.name})';
}

/// Stable error identities. User-facing text belongs to localization.
enum AppExceptionCode {
  network,
  api,
  parsing,
  unknown,
  configuration,
  authentication,
  storage,
  conflict,
}

/// Device is offline, DNS failed, or the request timed out.
final class NetworkException extends AppException {
  const NetworkException({super.cause}) : super(AppExceptionCode.network);
}

/// The server responded with a non-2xx status code.
final class ApiException extends AppException {
  const ApiException({required this.statusCode, super.cause})
    : super(AppExceptionCode.api);

  /// HTTP status code returned by the server.
  final int statusCode;
}

/// The response body could not be parsed into the expected model.
final class ParsingException extends AppException {
  const ParsingException({super.cause}) : super(AppExceptionCode.parsing);
}

/// Anything that does not fit the categories above.
final class UnknownException extends AppException {
  const UnknownException({super.cause}) : super(AppExceptionCode.unknown);
}

/// Required environment or vendor configuration is invalid.
final class ConfigurationException extends AppException {
  const ConfigurationException({super.cause})
    : super(AppExceptionCode.configuration);
}

/// Authentication is missing, expired, or rejected.
final class AuthenticationException extends AppException {
  const AuthenticationException({super.cause})
    : super(AppExceptionCode.authentication);
}

/// Local persistence failed.
final class StorageException extends AppException {
  const StorageException({super.cause}) : super(AppExceptionCode.storage);
}

/// A local mutation overlaps with a newer remote value.
final class ConflictException extends AppException {
  const ConflictException({super.cause}) : super(AppExceptionCode.conflict);
}

/// Maps a caught object into a typed [AppException].
///
/// Use this in every repository `catch` block:
/// ```dart
/// } on Exception catch (e) {
///   return Failure(mapToAppException(e));
/// }
/// ```
AppException mapToAppException(Object error) {
  if (error is AppException) return error;
  if (error is DioException) {
    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.connectionError => NetworkException(cause: error),
      DioExceptionType.badResponse => ApiException(
        statusCode: error.response?.statusCode ?? 0,
        cause: error,
      ),
      _ => UnknownException(cause: error),
    };
  }
  if (error is FormatException ||
      error is TypeError ||
      error is CheckedFromJsonException) {
    return ParsingException(cause: error);
  }
  return UnknownException(cause: error);
}
