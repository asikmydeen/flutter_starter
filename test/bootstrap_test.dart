import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_starter/bootstrap.dart';
import 'package:flutter_starter/core/config/app_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(AppConfig.resetForTesting);
  tearDown(AppConfig.resetForTesting);

  testWidgets('should initialize config and all global error handlers', (
    tester,
  ) async {
    final previousFlutterHandler = FlutterError.onError;
    final previousPlatformHandler = PlatformDispatcher.instance.onError;
    addTearDown(() {
      FlutterError.onError = previousFlutterHandler;
      PlatformDispatcher.instance.onError = previousPlatformHandler;
    });

    await bootstrap(
      () => const MaterialApp(home: Text('booted')),
      environment: 'dev',
      apiUrl: 'http://localhost:8080',
    );
    await tester.pump();

    expect(find.text('booted'), findsOneWidget);
    expect(AppConfig.instance.env, 'dev');
    expect(FlutterError.onError, isNotNull);
    expect(PlatformDispatcher.instance.onError, isNotNull);
    FlutterError.onError!(FlutterErrorDetails(exception: Exception('test')));
    expect(
      PlatformDispatcher.instance.onError!(Exception('test'), StackTrace.empty),
      isTrue,
    );
  });
}
