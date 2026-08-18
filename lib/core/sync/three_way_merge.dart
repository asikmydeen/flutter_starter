/// Result of comparing a base value with local and remote edits.
sealed class ThreeWayMergeResult {
  const ThreeWayMergeResult();
}

/// Local and remote edits do not overlap and can be synchronized.
final class MergedFields extends ThreeWayMergeResult {
  const MergedFields(this.value);

  final Map<String, Object?> value;
}

/// Local and remote edits overlap and require explicit resolution.
final class ConflictingFields extends ThreeWayMergeResult {
  const ConflictingFields(this.fields);

  final Set<String> fields;
}

/// Performs a field-level three-way merge.
///
/// A field conflicts only when local and remote both changed it from [base]
/// to different values. Equal concurrent edits and disjoint edits merge.
ThreeWayMergeResult mergeFields({
  required Map<String, Object?> base,
  required Map<String, Object?> local,
  required Map<String, Object?> remote,
}) {
  final keys = {...base.keys, ...local.keys, ...remote.keys};
  final merged = <String, Object?>{};
  final conflicts = <String>{};
  for (final key in keys) {
    final baseValue = base[key];
    final localValue = local[key];
    final remoteValue = remote[key];
    final localChanged =
        local.containsKey(key) != base.containsKey(key) ||
        localValue != baseValue;
    final remoteChanged =
        remote.containsKey(key) != base.containsKey(key) ||
        remoteValue != baseValue;
    if (localChanged && remoteChanged && localValue != remoteValue) {
      conflicts.add(key);
      continue;
    }
    final value = localChanged ? localValue : remoteValue;
    final exists = localChanged
        ? local.containsKey(key)
        : remote.containsKey(key);
    if (exists) merged[key] = value;
  }
  return conflicts.isEmpty
      ? MergedFields(merged)
      : ConflictingFields(conflicts);
}
