import 'dart:io';

String resolveTestDartExecutable() {
  final flutterRoot = Platform.environment['FLUTTER_ROOT'];
  if (flutterRoot != null) {
    final dart = File('$flutterRoot/bin/cache/dart-sdk/bin/dart');
    if (dart.existsSync()) return dart.path;
  }
  final fvmDart = File('.fvm/flutter_sdk/bin/cache/dart-sdk/bin/dart');
  if (fvmDart.existsSync()) return fvmDart.absolute.path;
  return 'dart';
}
