import 'package:flutter_starter/core/config/app_config.dart';

/// Initializes [AppConfig] for tests. Call in `setUp` (or at the top of
/// `main`) in any test that touches config-dependent code (dio client,
/// logger, ...). Safe to call repeatedly.
void setUpTestConfig() {
  AppConfig.resetForTesting();
  AppConfig.init('dev');
}
