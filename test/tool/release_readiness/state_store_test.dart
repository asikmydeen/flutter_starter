import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../../tool/src/release_readiness/model.dart';
import '../../../tool/src/release_readiness/state_store.dart';

void main() {
  test(
    'should atomically persist resumable state with private permissions',
    () {
      final root = Directory.systemTemp.createTempSync('readiness_state_');
      addTearDown(() => root.deleteSync(recursive: true));
      final file = File('${root.path}/state/state.json');
      final store = ReadinessStateStore(file);
      final state = ReadinessState.initial(inputsDigest: 'digest');

      store.save(state);
      final restored = store.load();

      expect(restored?.inputsDigest, 'digest');
      expect(File('${file.path}.tmp').existsSync(), isFalse);
      if (!Platform.isWindows) {
        expect(file.statSync().mode & 0x1FF, 0x180);
        expect(file.parent.statSync().mode & 0x1FF, 0x1C0);
      }
    },
  );
}
