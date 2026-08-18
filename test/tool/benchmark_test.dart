import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/src/benchmark.dart';
import '../helpers/dart_executable.dart';

void main() {
  test('should calculate nearest-rank p95 deterministically', () {
    final durations = [
      for (var value = 1; value <= 20; value++) Duration(seconds: value),
    ];

    expect(nearestRank(durations, 0.95), const Duration(seconds: 19));
    expect(() => nearestRank([], 0.95), throwsArgumentError);
    expect(() => nearestRank(durations, 0), throwsRangeError);
  });

  test('should report pass and failure against the threshold', () {
    final passing = BenchmarkReport(
      name: 'feature',
      durations: const [Duration(seconds: 1), Duration(seconds: 2)],
      threshold: const Duration(seconds: 2),
      command: const ['dart', '--version'],
      generatedAt: DateTime.utc(2026, 8, 17),
    );
    final failing = BenchmarkReport(
      name: 'feature',
      durations: const [Duration(seconds: 3)],
      threshold: const Duration(seconds: 2),
      command: const ['dart', '--version'],
      generatedAt: DateTime.utc(2026, 8, 17),
    );

    expect(passing.passed, isTrue);
    expect(failing.passed, isFalse);
    expect(passing.toJson()['runs'], 2);
  });

  test('should execute one warm-up plus every timed run', () async {
    final directory = Directory.systemTemp.createTempSync('benchmark_test_');
    addTearDown(() => directory.deleteSync(recursive: true));

    final report = await runBenchmark(
      name: 'echo',
      runs: 2,
      threshold: const Duration(seconds: 5),
      command: const ['true'],
      workingDirectory: directory,
    );

    expect(report.durations, hasLength(2));
    expect(report.passed, isTrue);
  });

  test('should write a machine-readable report', () async {
    final directory = Directory.systemTemp.createTempSync('benchmark_report_');
    addTearDown(() => directory.deleteSync(recursive: true));
    final output = File('${directory.path}/report.json');
    final report = BenchmarkReport(
      name: 'feature',
      durations: const [Duration(milliseconds: 10)],
      threshold: const Duration(seconds: 1),
      command: const ['true'],
      generatedAt: DateTime.utc(2026, 8, 17),
    );

    await writeBenchmarkReport(output, report);
    final decoded =
        jsonDecode(output.readAsStringSync())! as Map<String, Object?>;

    expect(decoded['passed'], isTrue);
    expect(decoded['p95Ms'], 10);
  });

  test(
    'should benchmark unique generated features through run placeholders',
    () async {
      final root = Directory.systemTemp.createTempSync('benchmark_feature_');
      addTearDown(() => root.deleteSync(recursive: true));
      Directory('${root.path}/.release-readiness').createSync(recursive: true);
      File('${root.path}/.release-readiness/state.json').writeAsStringSync(
        jsonEncode({
          'stage': 'READY',
          'inputsDigest': 'benchmark',
          'approvedDigest': 'benchmark',
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
      final script = File('tool/new_feature.dart').absolute.path;

      final report = await runBenchmark(
        name: 'feature-scaffold',
        runs: 2,
        threshold: const Duration(minutes: 1),
        command: [
          'env',
          'FEATURE_GENERATOR_ROOT=${root.path}',
          resolveTestDartExecutable(),
          script,
          'benchmark_{run}',
        ],
        workingDirectory: Directory.current,
      );

      expect(report.passed, isTrue);
      expect(
        Directory('${root.path}/lib/features/benchmark_1').existsSync(),
        isTrue,
      );
      expect(
        Directory('${root.path}/lib/features/benchmark_2').existsSync(),
        isTrue,
      );
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
