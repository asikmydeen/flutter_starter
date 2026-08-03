<!-- Keep PRs small and focused. Fill out every section. -->

## Summary

<!-- What does this PR do and why? 1–3 sentences. -->

Closes #<!-- issue number -->

## Type of change

- [ ] ✨ Feature (`feat`)
- [ ] 🐛 Bug fix (`fix`)
- [ ] ♻️ Refactor (no behavior change)
- [ ] 🧹 Chore / tooling (`chore`)
- [ ] 📝 Docs (`docs`)
- [ ] ✅ Tests (`test`)

## Changes

<!-- Bullet the key changes so reviewers can orient quickly. -->

-
-

## Screenshots / recordings

<!-- For any UI change, attach before/after screenshots or a screen recording. Delete if N/A. -->

## How to test

<!-- Steps a reviewer can follow to verify locally. -->

1.
2.

## Checklist

- [ ] Follows feature-first + layered structure (`data / domain / application / presentation`)
- [ ] Uses the standard stack (Riverpod, go_router, dio, freezed) — no new state lib
- [ ] No hardcoded secrets/env values (routed through `AppConfig` + `--dart-define`)
- [ ] Codegen regenerated (`dart run build_runner build --delete-conflicting-outputs`)
- [ ] `dart format .` applied
- [ ] `flutter analyze` clean
- [ ] `flutter test` green
- [ ] Added/updated tests for new logic
- [ ] Updated docs (README / AGENTS.md) if behavior or setup changed

## Notes for reviewers

<!-- Anything reviewers should pay special attention to, trade-offs, follow-ups, etc. -->
