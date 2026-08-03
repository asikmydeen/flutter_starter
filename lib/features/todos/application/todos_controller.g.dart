// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todos_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Binds the [TodosRepository] interface to its HTTP implementation.
/// Tests override this provider with a mock — see
/// `test/features/todos/application/todos_controller_test.dart`.

@ProviderFor(todosRepository)
final todosRepositoryProvider = TodosRepositoryProvider._();

/// Binds the [TodosRepository] interface to its HTTP implementation.
/// Tests override this provider with a mock — see
/// `test/features/todos/application/todos_controller_test.dart`.

final class TodosRepositoryProvider
    extends
        $FunctionalProvider<TodosRepository, TodosRepository, TodosRepository>
    with $Provider<TodosRepository> {
  /// Binds the [TodosRepository] interface to its HTTP implementation.
  /// Tests override this provider with a mock — see
  /// `test/features/todos/application/todos_controller_test.dart`.
  TodosRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todosRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todosRepositoryHash();

  @$internal
  @override
  $ProviderElement<TodosRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TodosRepository create(Ref ref) {
    return todosRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TodosRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TodosRepository>(value),
    );
  }
}

String _$todosRepositoryHash() => r'8d90d0780f6341852c2677b1bb075dd9e2280dad';

/// The reference async controller pattern.
///
/// `build` loads the data; [Result] failures are rethrown as the typed
/// `AppException` so Riverpod exposes them as `AsyncError` — the screen
/// renders `error.message` and offers a retry.

@ProviderFor(TodosController)
final todosControllerProvider = TodosControllerProvider._();

/// The reference async controller pattern.
///
/// `build` loads the data; [Result] failures are rethrown as the typed
/// `AppException` so Riverpod exposes them as `AsyncError` — the screen
/// renders `error.message` and offers a retry.
final class TodosControllerProvider
    extends $AsyncNotifierProvider<TodosController, List<Todo>> {
  /// The reference async controller pattern.
  ///
  /// `build` loads the data; [Result] failures are rethrown as the typed
  /// `AppException` so Riverpod exposes them as `AsyncError` — the screen
  /// renders `error.message` and offers a retry.
  TodosControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todosControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todosControllerHash();

  @$internal
  @override
  TodosController create() => TodosController();
}

String _$todosControllerHash() => r'fec44244d88d1d3f595c21381eed966113f4ff28';

/// The reference async controller pattern.
///
/// `build` loads the data; [Result] failures are rethrown as the typed
/// `AppException` so Riverpod exposes them as `AsyncError` — the screen
/// renders `error.message` and offers a retry.

abstract class _$TodosController extends $AsyncNotifier<List<Todo>> {
  FutureOr<List<Todo>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Todo>>, List<Todo>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Todo>>, List<Todo>>,
              AsyncValue<List<Todo>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
