import 'package:flutter_starter/core/config/app_config.dart';
import 'package:flutter_starter/main.dart' as app_main;
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'should fail closed when compile-time configuration is absent',
    () async {
      AppConfig.resetForTesting();
      addTearDown(AppConfig.resetForTesting);

      await expectLater(app_main.main(), throwsArgumentError);
    },
  );
}
