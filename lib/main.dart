import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/config/app_config.dart';

void main() {
  // Read compile-time env (pass with --dart-define=ENV=dev|staging|prod).
  const env = String.fromEnvironment('ENV', defaultValue: 'dev');
  AppConfig.init(env);

  runApp(const ProviderScope(child: MyApp()));
}
