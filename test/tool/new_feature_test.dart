import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final script = File('tool/new_feature.dart').absolute.path;

  test(
    'should block generation until readiness is digest-bound READY',
    () async {
      final root = Directory.systemTemp.createTempSync('feature_blocked_');
      addTearDown(() => root.deleteSync(recursive: true));
      Directory('${root.path}/.release-readiness').createSync();
      File('${root.path}/.release-readiness/state.json').writeAsStringSync(
        jsonEncode({
          'stage': 'DRAFT',
          'inputsDigest': 'current',
          'approvedDigest': null,
        }),
      );
      Directory('${root.path}/lib/core/router').createSync(recursive: true);
      File('${root.path}/lib/core/router/app_router.dart').writeAsStringSync('''
import 'package:go_router/go_router.dart';
// feature-generator-imports
abstract final class RouteNames {
  // feature-generator-route-names
}
final routes = <GoRoute>[
  // feature-generator-routes
];
''');
      Directory('${root.path}/lib/l10n/arb').createSync(recursive: true);
      File('${root.path}/lib/l10n/arb/app_en.arb').writeAsStringSync('{}');
      File('${root.path}/starter.yaml').writeAsStringSync('''
project:
  packageName: generated_app
''');

      final result = await _runGenerator(script, root, 'orders');

      expect(result.exitCode, 3);
      expect(
        Directory('${root.path}/lib/features/orders').existsSync(),
        isFalse,
      );
    },
  );

  test(
    'should generate complete formatted files without TODO markers',
    () async {
      final root = Directory.systemTemp.createTempSync('feature_ready_');
      addTearDown(() => root.deleteSync(recursive: true));
      Directory('${root.path}/.release-readiness').createSync();
      File('${root.path}/.release-readiness/state.json').writeAsStringSync(
        jsonEncode({
          'stage': 'READY',
          'inputsDigest': 'approved',
          'approvedDigest': 'approved',
        }),
      );
      Directory('${root.path}/lib/core/router').createSync(recursive: true);
      File('${root.path}/lib/core/router/app_router.dart').writeAsStringSync('''
import 'package:go_router/go_router.dart';
// feature-generator-imports
abstract final class RouteNames {
  // feature-generator-route-names
}
final routes = <GoRoute>[
  // feature-generator-routes
];
''');
      Directory('${root.path}/lib/l10n/arb').createSync(recursive: true);
      File('${root.path}/lib/l10n/arb/app_en.arb').writeAsStringSync('{}');
      File('${root.path}/starter.yaml').writeAsStringSync('''
project:
  packageName: generated_app
''');

      final result = await _runGenerator(script, root, 'orders');

      expect(result.exitCode, 0, reason: '${result.stderr}');
      final generated = Directory(root.path)
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'))
          .where(
            (file) =>
                file.path.contains('/lib/features/orders/') ||
                file.path.contains('/test/features/orders/'),
          )
          .toList();
      expect(generated, hasLength(9));
      expect(
        generated.any((file) => file.readAsStringSync().contains('TODO')),
        isFalse,
      );
      expect(
        generated.any(
          (file) => file.readAsStringSync().contains('package:generated_app/'),
        ),
        isTrue,
      );
      expect(
        File('${root.path}/lib/core/router/app_router.dart').readAsStringSync(),
        contains("static const orders = 'orders';"),
      );
      final arb =
          jsonDecode(
                File('${root.path}/lib/l10n/arb/app_en.arb').readAsStringSync(),
              )!
              as Map<String, dynamic>;
      expect(arb['ordersTitle'], 'Orders');
    },
  );

  test('should reject invalid names before writing', () async {
    final root = Directory.systemTemp.createTempSync('feature_invalid_');
    addTearDown(() => root.deleteSync(recursive: true));

    final result = await _runGenerator(script, root, 'Invalid-Name');

    expect(result.exitCode, 64);
    expect(Directory('${root.path}/lib').existsSync(), isFalse);
  });
}

Future<ProcessResult> _runGenerator(
  String script,
  Directory root,
  String name,
) {
  return Process.run(
    'fvm',
    ['dart', 'run', script, name],
    environment: {
      ...Platform.environment,
      'FEATURE_GENERATOR_ROOT': root.path,
    },
  );
}
