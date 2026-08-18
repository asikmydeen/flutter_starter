import 'package:flutter_starter/core/sync/three_way_merge.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('should preserve unchanged fields', () {
    final result = mergeFields(
      base: const {'title': 'old', 'completed': false},
      local: const {'title': 'old', 'completed': false},
      remote: const {'title': 'old', 'completed': false},
    );

    expect((result as MergedFields).value, {
      'title': 'old',
      'completed': false,
    });
  });

  test('should merge disjoint local and remote edits', () {
    final result = mergeFields(
      base: const {'title': 'old', 'completed': false},
      local: const {'title': 'local', 'completed': false},
      remote: const {'title': 'old', 'completed': true},
    );

    expect((result as MergedFields).value, {
      'title': 'local',
      'completed': true,
    });
  });

  test('should merge equal concurrent edits', () {
    final result = mergeFields(
      base: const {'title': 'old'},
      local: const {'title': 'same'},
      remote: const {'title': 'same'},
    );

    expect((result as MergedFields).value['title'], 'same');
  });

  test('should preserve field deletion from either side', () {
    final localDelete = mergeFields(
      base: const {'title': 'old', 'completed': false},
      local: const {'completed': false},
      remote: const {'title': 'old', 'completed': false},
    );
    final remoteDelete = mergeFields(
      base: const {'title': 'old', 'completed': false},
      local: const {'title': 'old', 'completed': false},
      remote: const {'completed': false},
    );

    expect((localDelete as MergedFields).value, {'completed': false});
    expect((remoteDelete as MergedFields).value, {'completed': false});
  });

  test('should report every overlapping field', () {
    final result = mergeFields(
      base: const {'title': 'old', 'completed': false},
      local: const {'title': 'local', 'completed': true},
      remote: const {'title': 'remote', 'completed': null},
    );

    expect(
      (result as ConflictingFields).fields,
      {'title', 'completed'},
    );
  });
}
