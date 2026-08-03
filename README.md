# Flutter Starter

Production-shaped Flutter template optimized for **agentic (AI-driven) development**:
feature-first + Riverpod 3 (codegen) + go_router + dio + freezed 3, with a
reference feature, mechanically enforced conventions, and one-command verification.

**AI agents: read `AGENTS.md` first.** It is the operating manual.

## Quick start

```bash
fvm install && fvm use        # SDK pinned in .fvmrc
make setup                    # deps + l10n + codegen
make run                      # run (dev flavor)
./tool/verify.sh              # the definition of done
```

## What makes this template agent-proof

- **Pinned everything** — exact Flutter version in `.fvmrc` (CI reads the
  same file), `pubspec.lock` committed, generated code committed with a CI
  drift gate.
- **One verification command** — `./tool/verify.sh` runs deps, l10n, codegen,
  format, analyze, tests, and a coverage floor. CI runs the identical script.
- **Reference feature** — `lib/features/todos/` exercises every layer
  (freezed entity, DTO, dio repository returning `Result`, `@riverpod` async
  controller, screen with full `AsyncValue` handling) with a matching test
  for each layer. New code mirrors it.
- **Feature generator** — `make feature NAME=x` stamps the canonical layout
  with test skeletons; no hand-rolled structure drift.
- **Typed failures** — sealed `Result` + `AppException`; repositories never
  throw, screens always render loading/data/error.
- **Guardrails in CI** — format, analyze, tests, coverage floor, Android
  smoke build, secret scanning (gitleaks), dependency CVE audit (osv-scanner).

## Structure

```
lib/
├── bootstrap.dart        # config init + ALL global error handling
├── core/                 # cross-cutting: config, error, logging, network,
│   │                     #   result, router, theme
│   └── ...
├── features/
│   ├── counter/          # minimal sync-notifier example
│   ├── home/
│   └── todos/            # ★ REFERENCE FEATURE — mirror this
│       ├── domain/       # entity (freezed) + repository interface
│       ├── data/         # DTO (json) + dio repository → Result
│       ├── application/  # @riverpod async controller
│       └── presentation/ # screen with exhaustive AsyncValue switch
├── l10n/                 # ARB sources + generated localizations
└── main.dart
tool/
├── verify.sh             # the definition of done (CI runs the same)
└── new_feature.dart      # feature scaffolder
```

## Environments

```bash
flutter run --dart-define=ENV=dev
flutter build appbundle --dart-define=ENV=prod
flutter build ipa       --dart-define=ENV=prod
```

Unknown `ENV` values fail at startup by design. All env-dependent values go
through `lib/core/config/app_config.dart`.

## Testing

```bash
make test        # unit + widget (goldens excluded)
make goldens     # regenerate golden screenshots after UI changes
make verify      # everything, with coverage floor
```

## Building an app with an AI agent

Point the agent at this repo with your requirements (written spec, a
reference website/app, or a rough idea). AGENTS.md gates it through:

1. **Intake** (`docs/INTAKE.md`) — the agent interviews you: scope, backend,
   auth, design source, platforms. Every question has a default, so you can
   answer "defaults fine, except…". Answers land in `docs/PRODUCT_SPEC.md`.
2. **Spec approval** — one document to review before any code is written.
3. **Build loop** — walking skeleton first, then one verified feature per
   cycle, with the spec tracking milestone status so any session can resume.

## New project?

Follow `docs/NEW_PROJECT.md` (identity, branding, signing, stores).
