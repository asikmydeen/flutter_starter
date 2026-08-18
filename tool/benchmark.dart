import 'dart:io';

import 'package:args/args.dart';

import 'src/benchmark.dart';

Future<void> main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('name', defaultsTo: 'feature-scaffold')
    ..addOption('runs', defaultsTo: '20')
    ..addOption('threshold-seconds', defaultsTo: '300')
    ..addOption('working-directory', mandatory: true)
    ..addOption('output', mandatory: true);
  final separator = arguments.indexOf('--');
  if (separator < 0 || separator == arguments.length - 1) {
    stderr.writeln('Usage: benchmark [options] -- <command> [arguments]');
    exitCode = 64;
    return;
  }
  final options = parser.parse(arguments.take(separator).toList());
  final command = arguments.skip(separator + 1).toList();
  try {
    final report = await runBenchmark(
      name: options['name']! as String,
      runs: int.parse(options['runs']! as String),
      threshold: Duration(
        seconds: int.parse(options['threshold-seconds']! as String),
      ),
      command: command,
      workingDirectory: Directory(options['working-directory']! as String),
    );
    await writeBenchmarkReport(File(options['output']! as String), report);
    stdout.writeln(
      '${report.name}: p95=${report.p95.inMilliseconds}ms '
      'threshold=${report.threshold.inMilliseconds}ms',
    );
    if (!report.passed) exitCode = 1;
  } on FormatException catch (error) {
    stderr.writeln(error.message);
    exitCode = 64;
  } on ProcessException catch (error) {
    stderr.writeln(error.message);
    exitCode = error.errorCode;
  }
}
