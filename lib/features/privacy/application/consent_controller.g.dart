// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'consent_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ConsentController)
final consentControllerProvider = ConsentControllerProvider._();

final class ConsentControllerProvider
    extends $NotifierProvider<ConsentController, bool> {
  ConsentControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'consentControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$consentControllerHash();

  @$internal
  @override
  ConsentController create() => ConsentController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$consentControllerHash() => r'b213715c0733867730adb3b01358dcec95a6f6c0';

abstract class _$ConsentController extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
