import 'dart:convert';
import 'dart:io';
import 'dart:math';

final class BenchmarkReport {
  const BenchmarkReport({
    required this.name,
    required this.durations,
    required this.threshold,
    required this.command,
    required this.generatedAt,
  });

  final String name;
  final List<Duration> durations;
  final Duration threshold;
  final List<String> command;
  final DateTime generatedAt;

  Duration get p95 => nearestRank(durations, 0.95);
  bool get passed => durations.isNotEmpty && p95 <= threshold;

  Map<String, Object?> toJson() => {
    'schemaVersion': 1,
    'name': name,
    'runs': durations.length,
    'durationsMs': durations.map((value) => value.inMilliseconds).toList(),
    'p95Ms': p95.inMilliseconds,
    'thresholdMs': threshold.inMilliseconds,
    'passed': passed,
    'command': command,
    'generatedAt': generatedAt.toUtc().toIso8601String(),
    'os': Platform.operatingSystem,
    'osVersion': Platform.operatingSystemVersion,
    'processors': Platform.numberOfProcessors,
    'dartVersion': Platform.version,
  };
}

Duration nearestRank(List<Duration> values, double percentile) {
  if (values.isEmpty) throw ArgumentError('values cannot be empty');
  if (percentile <= 0 || percentile > 1) {
    throw RangeError.range(percentile, 0, 1, 'percentile');
  }
  final sorted = [...values]..sort();
  final rank = max(1, (percentile * sorted.length).ceil());
  return sorted[rank - 1];
}

Future<BenchmarkReport> runBenchmark({
  required String name,
  required int runs,
  required Duration threshold,
  required List<String> command,
  required Directory workingDirectory,
}) async {
  if (runs < 1) throw ArgumentError.value(runs, 'runs', 'must be positive');
  if (command.isEmpty) throw ArgumentError('command cannot be empty');

  await _run(command, workingDirectory, warmup: true, runIndex: 0);
  final durations = <Duration>[];
  for (var index = 0; index < runs; index++) {
    final stopwatch = Stopwatch()..start();
    await _run(
      command,
      workingDirectory,
      warmup: false,
      runIndex: index + 1,
    );
    stopwatch.stop();
    durations.add(stopwatch.elapsed);
  }
  return BenchmarkReport(
    name: name,
    durations: durations,
    threshold: threshold,
    command: command,
    generatedAt: DateTime.now().toUtc(),
  );
}

Future<void> writeBenchmarkReport(File output, BenchmarkReport report) async {
  output.parent.createSync(recursive: true);
  await output.writeAsString(
    const JsonEncoder.withIndent('  ').convert(report.toJson()),
    flush: true,
  );
}

Future<void> _run(
  List<String> command,
  Directory workingDirectory, {
  required bool warmup,
  required int runIndex,
}) async {
  final expanded = command
      .map((argument) => argument.replaceAll('{run}', '$runIndex'))
      .toList(growable: false);
  final result = await Process.run(
    expanded.first,
    expanded.skip(1).toList(),
    workingDirectory: workingDirectory.path,
  );
  if (result.exitCode != 0) {
    throw ProcessException(
      expanded.first,
      expanded.skip(1).toList(),
      '${warmup ? 'Warm-up' : 'Timed run'} failed with exit '
      '${result.exitCode}',
      result.exitCode,
    );
  }
}
