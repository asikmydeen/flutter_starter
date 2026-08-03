import 'package:flutter_starter/core/error/app_exception.dart';

/// The return type for every data-layer method that can fail.
///
/// Repositories never throw — they return `Success` or `Failure` so callers
/// are forced by the type system (exhaustive `switch`) to handle both paths.
///
/// ```dart
/// final result = await repository.fetchTodos();
/// switch (result) {
///   case Success(:final value):
///     // use value
///   case Failure(:final error):
///     // surface error.message
/// }
/// ```
sealed class Result<T> {
  const Result();
}

/// The operation succeeded with [value].
final class Success<T> extends Result<T> {
  const Success(this.value);

  /// The successful payload.
  final T value;
}

/// The operation failed with a typed [error].
final class Failure<T> extends Result<T> {
  const Failure(this.error);

  /// What went wrong. Always an [AppException], never a raw exception.
  final AppException error;
}

/// Convenience accessors used by controllers and tests.
extension ResultX<T> on Result<T> {
  /// Returns the value or throws the typed error. Prefer `switch` in
  /// production code; this is mainly useful in controllers that map
  /// failures into `AsyncError` (Riverpod catches the throw).
  T get valueOrThrow => switch (this) {
    Success(:final value) => value,
    Failure(:final error) => throw error,
  };

  /// Transforms the success value, passing failures through unchanged.
  Result<R> map<R>(R Function(T value) transform) => switch (this) {
    Success(:final value) => Success(transform(value)),
    Failure(:final error) => Failure(error),
  };
}
