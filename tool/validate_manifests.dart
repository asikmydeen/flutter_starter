import 'dart:convert';
import 'dart:io';

import 'package:yaml/yaml.dart';

void main() {
  final starter = loadYaml(File('starter.yaml').readAsStringSync())! as YamlMap;
  final platforms = starter['platforms']! as YamlMap;
  final android = platforms['android']! as YamlMap;
  final ios = platforms['ios']! as YamlMap;
  if (android['minSdk'] != 24 || android['targetSdk'] != 36) {
    _fail('starter.yaml must use Android minSdk 24 and targetSdk 36');
  }
  if (ios['minimumVersion'] != '13.0') {
    _fail('starter.yaml must use iOS minimum version 13.0');
  }
  final project = starter['project']! as YamlMap;
  for (final identifier in [
    project['organization'],
    android['applicationId'],
    ios['bundleId'],
  ]) {
    if ('$identifier'.contains('example')) {
      _fail('starter.yaml contains an example identifier');
    }
  }
  final environments = starter['environments']! as YamlMap;
  if (!const {'dev', 'staging', 'prod'}.every(environments.containsKey)) {
    _fail('starter.yaml must define dev, staging, and prod independently');
  }

  for (final path in [
    'config/release_readiness.json',
    'config/security/license-policy.json',
    'config/security/dependency-waivers.json',
    'metadata/store/store-metadata.json',
    'metadata/store/assets/manifest.json',
    'tool/benchmarks/baseline.json',
  ]) {
    final decoded = jsonDecode(File(path).readAsStringSync());
    if (decoded is! Map<String, dynamic> || decoded['schemaVersion'] != 1) {
      _fail('$path must be a schemaVersion 1 JSON object');
    }
  }
  stdout.writeln('Manifest validation passed.');
}

Never _fail(String message) {
  stderr.writeln('ERROR: $message');
  exit(1);
}
