import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:yaml/yaml.dart';

/// Computes the canonical digest that approvals and READY bind to.
String computeInputsDigest({
  required String starterYaml,
  required Map<String, Object?> readinessManifest,
  required String toolVersion,
}) {
  final manifest = Map<String, Object?>.from(readinessManifest)
    ..remove('stage')
    ..remove('approval')
    ..remove('updatedAt')
    ..remove('inputsDigest');
  final input = {
    'starter': _normalizeYaml(loadYaml(starterYaml)),
    'readiness': manifest,
    'toolVersion': toolVersion,
  };
  return sha256.convert(utf8.encode(_canonicalJson(input))).toString();
}

/// Computes a non-reversible secret fingerprint for comparison and rotation.
String fingerprintSecret(List<int> bytes) => sha256.convert(bytes).toString();

Object? _normalizeYaml(Object? value) => switch (value) {
  final YamlMap map => {
    for (final entry in map.entries)
      entry.key.toString(): _normalizeYaml(entry.value),
  },
  final YamlList list => list.map(_normalizeYaml).toList(),
  _ => value,
};

String _canonicalJson(Object? value) => switch (value) {
  final Map<Object?, Object?> map => () {
    final keys = map.keys.map((key) => key.toString()).toList()..sort();
    final entries = keys.map(
      (key) => '${jsonEncode(key)}:${_canonicalJson(map[key])}',
    );
    return '{${entries.join(',')}}';
  }(),
  final List<Object?> list => '[${list.map(_canonicalJson).join(',')}]',
  _ => jsonEncode(value),
};
