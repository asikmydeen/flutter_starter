import 'dart:convert';
import 'dart:io';

import 'model.dart';

/// Atomic, permission-restricted persistence for resumable readiness state.
final class ReadinessStateStore {
  const ReadinessStateStore(this.file);

  final File file;

  /// Loads existing state, or returns null before initialization.
  ReadinessState? load() {
    if (!file.existsSync()) return null;
    final value = jsonDecode(file.readAsStringSync())! as Map<String, Object?>;
    return ReadinessState.fromJson(value);
  }

  /// Writes through a sibling temporary file and atomically renames it.
  void save(ReadinessState state) {
    file.parent.createSync(recursive: true);
    _chmod('700', file.parent.path);
    final temporary = File('${file.path}.tmp')
      ..writeAsStringSync(
        const JsonEncoder.withIndent('  ').convert(state.toJson()),
        flush: true,
      );
    _chmod('600', temporary.path);
    temporary.renameSync(file.path);
    _chmod('600', file.path);
  }

  void _chmod(String mode, String path) {
    if (Platform.isWindows) return;
    final result = Process.runSync('chmod', [mode, path]);
    if (result.exitCode != 0) {
      throw FileSystemException('Unable to set mode $mode', path);
    }
  }
}
