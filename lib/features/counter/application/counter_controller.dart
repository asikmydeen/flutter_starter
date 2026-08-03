import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'counter_controller.g.dart';

/// Minimal synchronous Riverpod notifier demonstrating the application
/// layer with codegen. For the async / data-backed pattern, see
/// `features/todos/application/todos_controller.dart`.
@riverpod
class Counter extends _$Counter {
  @override
  int build() => 0;

  /// Increases the count by one.
  void increment() => state++;

  /// Decreases the count by one, clamped at zero.
  void decrement() => state = state > 0 ? state - 1 : 0;

  /// Resets the count to zero.
  void reset() => state = 0;
}
