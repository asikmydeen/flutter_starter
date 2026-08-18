import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart' as p;

void main(List<String> arguments) {
  final parser = ArgParser()
    ..addOption('lcov', defaultsTo: 'coverage/lcov.info')
    ..addOption('global-min', defaultsTo: '90')
    ..addOption('critical-min', defaultsTo: '95');
  final options = parser.parse(arguments);
  final records = _parseLcov(File(options['lcov']! as String));
  final sources = Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .where((file) => !_isGenerated(file.path))
      .toList();
  var total = 0;
  var hit = 0;
  var criticalTotal = 0;
  var criticalHit = 0;
  final missing = <String>[];
  final fileCoverage = <_FileCoverage>[];
  for (final source in sources) {
    final path = p.normalize(source.path);
    final record = records[path] ?? records[p.absolute(path)];
    final isCritical = RegExp(
      '^lib/core/(auth|config|database|sync)/',
    ).hasMatch(path);
    final found = record?.found ?? _countExecutableLines(source);
    final covered = record?.hit ?? 0;
    total += found;
    hit += covered;
    fileCoverage.add(_FileCoverage(path, found, covered));
    if (record == null && found > 0) missing.add(path);
    if (isCritical) {
      criticalTotal += found;
      criticalHit += covered;
    }
  }
  final globalPercent = total == 0 ? 0 : hit * 100 / total;
  final criticalPercent = criticalTotal == 0
      ? 100
      : criticalHit * 100 / criticalTotal;
  stdout
    ..writeln(
      'Handwritten line coverage: ${globalPercent.toStringAsFixed(1)}% '
      '($hit/$total)',
    )
    ..writeln(
      'Critical line coverage: ${criticalPercent.toStringAsFixed(1)}% '
      '($criticalHit/$criticalTotal)',
    );
  if (missing.isNotEmpty) {
    stdout.writeln('Uncovered files absent from LCOV: ${missing.join(', ')}');
  }
  fileCoverage
    ..sort((a, b) => a.percent.compareTo(b.percent))
    ..where((item) => item.hit < item.found).forEach(
      (item) => stdout.writeln(
        '${item.percent.toStringAsFixed(1).padLeft(5)}% '
        '${item.hit}/${item.found} ${item.path}',
      ),
    );
  final globalMin = double.parse(options['global-min']! as String);
  final criticalMin = double.parse(options['critical-min']! as String);
  if (globalPercent < globalMin || criticalPercent < criticalMin) {
    stderr.writeln(
      'ERROR: coverage is below the required '
      '${globalMin.toStringAsFixed(0)}%/${criticalMin.toStringAsFixed(0)}% '
      'global/critical floors.',
    );
    exit(1);
  }
}

Map<String, _Coverage> _parseLcov(File file) {
  if (!file.existsSync()) {
    throw StateError('No LCOV file found at ${file.path}');
  }
  final result = <String, _Coverage>{};
  String? source;
  var found = 0;
  var hit = 0;
  for (final line in file.readAsLinesSync()) {
    if (line.startsWith('SF:')) source = p.normalize(line.substring(3));
    if (line.startsWith('LF:')) found = int.parse(line.substring(3));
    if (line.startsWith('LH:')) hit = int.parse(line.substring(3));
    if (line == 'end_of_record' && source != null) {
      if (!_isGenerated(source)) result[source] = _Coverage(found, hit);
      source = null;
      found = 0;
      hit = 0;
    }
  }
  return result;
}

bool _isGenerated(String path) =>
    path.endsWith('.g.dart') ||
    path.endsWith('.freezed.dart') ||
    path.contains('${p.separator}l10n${p.separator}gen${p.separator}');

int _countExecutableLines(File file) {
  final contents = file.readAsStringSync();
  final isDeclarative =
      (contents.contains('@freezed') ||
          contents.contains('abstract interface class')) &&
      !contents.contains('=>');
  if (isDeclarative) return 0;
  var inBlockComment = false;
  var count = 0;
  for (final rawLine in file.readAsLinesSync()) {
    final line = rawLine.trim();
    if (line.startsWith('/*')) inBlockComment = true;
    if (inBlockComment) {
      if (line.contains('*/')) inBlockComment = false;
      continue;
    }
    if (line.isEmpty ||
        line.startsWith('//') ||
        line.startsWith('import ') ||
        line.startsWith('export ') ||
        line.startsWith('part ') ||
        line.startsWith('@') ||
        line == '{' ||
        line == '}' ||
        line == '};') {
      continue;
    }
    count++;
  }
  return count;
}

final class _Coverage {
  const _Coverage(this.found, this.hit);

  final int found;
  final int hit;
}

final class _FileCoverage {
  const _FileCoverage(this.path, this.found, this.hit);

  final String path;
  final int found;
  final int hit;

  double get percent => found == 0 ? 100 : hit * 100 / found;
}
