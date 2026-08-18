import 'package:flutter_test/flutter_test.dart';

import '../../../tool/src/release_readiness/digest.dart';

void main() {
  test('should produce the same digest for differently ordered maps', () {
    const starter = 'schemaVersion: 1\nproject:\n  name: starter\n';

    final first = computeInputsDigest(
      starterYaml: starter,
      readinessManifest: const {
        'schemaVersion': 1,
        'toolVersion': '1.0.0',
        'answers': {'b': 2, 'a': 1},
        'stage': 'DRAFT',
      },
      toolVersion: '1.0.0',
    );
    final second = computeInputsDigest(
      starterYaml: starter,
      readinessManifest: const {
        'answers': {'a': 1, 'b': 2},
        'toolVersion': '1.0.0',
        'schemaVersion': 1,
        'stage': 'READY',
      },
      toolVersion: '1.0.0',
    );

    expect(first, second);
  });

  test('should change the digest when an answer changes', () {
    const starter = 'schemaVersion: 1\n';
    final first = computeInputsDigest(
      starterYaml: starter,
      readinessManifest: const {
        'answers': {'country': 'US'},
      },
      toolVersion: '1.0.0',
    );
    final second = computeInputsDigest(
      starterYaml: starter,
      readinessManifest: const {
        'answers': {'country': 'GB'},
      },
      toolVersion: '1.0.0',
    );

    expect(first, isNot(second));
  });
}
