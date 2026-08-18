import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../../tool/src/release_readiness/secret_reference.dart';

void main() {
  late Directory root;
  late Directory secrets;

  setUp(() {
    root = Directory.systemTemp.createTempSync('readiness_repo_');
    secrets = Directory.systemTemp.createTempSync('readiness_secrets_');
    if (!Platform.isWindows) {
      Process.runSync('chmod', ['700', secrets.path]);
    }
  });

  tearDown(() {
    root.deleteSync(recursive: true);
    secrets.deleteSync(recursive: true);
  });

  test('should accept a 0600 file in a 0700 external directory', () {
    final file = File('${secrets.path}/secret.p8')..writeAsStringSync('secret');
    if (!Platform.isWindows) Process.runSync('chmod', ['600', file.path]);

    final result = SecretReference.parse('file://${file.path}').validate(
      repositoryRoot: root,
    );

    expect(result.isValid, isTrue);
    expect(result.fingerprint, isNotEmpty);
  });

  test('should reject credential files inside the repository', () {
    final file = File('${root.path}/secret.p8')..writeAsStringSync('secret');
    if (!Platform.isWindows) Process.runSync('chmod', ['600', file.path]);

    final result = SecretReference.parse('file://${file.path}').validate(
      repositoryRoot: root,
    );

    expect(result.isValid, isFalse);
    expect(result.error, contains('outside'));
  });

  test('should reject direct symlinks', () {
    final target = File('${secrets.path}/target.p8')
      ..writeAsStringSync('secret');
    final link = Link('${secrets.path}/link.p8')..createSync(target.path);

    final result = SecretReference.parse('file://${link.path}').validate(
      repositoryRoot: root,
    );

    expect(result.isValid, isFalse);
    expect(result.error, contains('symlink'));
  });

  test('should parse keychain references without reading a value', () {
    final result = SecretReference.parse(
      'keychain://flutter-starter/android-key',
    ).validate(repositoryRoot: root);

    expect(result.isValid, isTrue);
    expect(result.fingerprint, 'keychain-managed');
  });
}
