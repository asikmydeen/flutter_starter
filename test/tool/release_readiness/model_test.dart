import 'package:flutter_test/flutter_test.dart';

import '../../../tool/src/release_readiness/model.dart';

void main() {
  group('ReadinessState', () {
    test('should advance one stage at a time', () {
      final state = ReadinessState.initial(inputsDigest: 'digest');

      final answered = state.advance(ReadinessStage.answered);

      expect(answered.stage, ReadinessStage.answered);
      expect(answered.inputsDigest, 'digest');
    });

    test('should reject skipped stages', () {
      final state = ReadinessState.initial(inputsDigest: 'digest');

      expect(
        () => state.advance(ReadinessStage.resourcesValidated),
        throwsStateError,
      );
    });

    test('should round-trip redacted state', () {
      final state = ReadinessState.initial(inputsDigest: 'digest').copyWith(
        answers: const {'publisherLegalName': 'Example'},
        blockers: const [
          ReadinessBlocker(
            kind: BlockerKind.missingInput,
            checkId: 'answer.supportEmail',
            message: 'missing support email',
            resumeStage: ReadinessStage.draft,
          ),
        ],
      );

      final parsed = ReadinessState.fromJson(state.toJson());

      expect(parsed.stage, state.stage);
      expect(parsed.answers, state.answers);
      expect(parsed.blockers.single.checkId, 'answer.supportEmail');
    });
  });
}
