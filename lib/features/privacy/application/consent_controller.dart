import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'consent_controller.g.dart';

@riverpod
class ConsentController extends _$ConsentController {
  @override
  bool build() => false;

  bool get analyticsConsent => state;

  set analyticsConsent(bool enabled) => state = enabled;
}
