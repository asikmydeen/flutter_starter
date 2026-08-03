// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'counter_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Minimal synchronous Riverpod notifier demonstrating the application
/// layer with codegen. For the async / data-backed pattern, see
/// `features/todos/application/todos_controller.dart`.

@ProviderFor(Counter)
final counterProvider = CounterProvider._();

/// Minimal synchronous Riverpod notifier demonstrating the application
/// layer with codegen. For the async / data-backed pattern, see
/// `features/todos/application/todos_controller.dart`.
final class CounterProvider extends $NotifierProvider<Counter, int> {
  /// Minimal synchronous Riverpod notifier demonstrating the application
  /// layer with codegen. For the async / data-backed pattern, see
  /// `features/todos/application/todos_controller.dart`.
  CounterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'counterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$counterHash();

  @$internal
  @override
  Counter create() => Counter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$counterHash() => r'86dbb19641c7adf13ab881f4be4e8ea0603d3ab3';

/// Minimal synchronous Riverpod notifier demonstrating the application
/// layer with codegen. For the async / data-backed pattern, see
/// `features/todos/application/todos_controller.dart`.

abstract class _$Counter extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
