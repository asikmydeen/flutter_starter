import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';

/// The closed set of failures the data layer can produce.
///
/// Every repository maps raw exceptions (Dio errors, format errors, ...)
/// into one of these before returning a `Failure`. UI code only ever deals
/// with [AppException] — never with transport-level exceptions.
sealed class AppException implements Exception {
  const AppException(this.message, {this.cause});

  /// Human-readable summary, safe to log and to show to users.
  final String message;

  /// The original exception, kept for logs — never shown to users.
  final Object? cause;

  @override
  String toString() => 'AppException: $message';
}

/// Device is offline, DNS failed, or the request timed out.
final class NetworkException extends AppException {
  const NetworkException({super.cause})
    : super('Could not reach the server. Check your connection.');
}

/// The server responded with a non-2xx status code.
final class ApiException extends AppException {
  const ApiException({required this.statusCode, super.cause})
    : super('The server returned an error ($statusCode).');

  /// HTTP status code returned by the server.
  final int statusCode;
}

/// The response body could not be parsed into the expected model.
final class ParsingException extends AppException {
  const ParsingException({super.cause})
    : super('Received an unexpected response format.');
}

/// Anything that does not fit the categories above.
final class UnknownException extends AppException {
  const UnknownException({super.cause})
    : super('Something went wrong. Please try again.');
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
