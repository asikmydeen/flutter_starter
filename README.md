# Flutter Starter

Opinionated Flutter production starter for secure API-backed, enterprise, and
offline-capable iOS/Android apps. The approved target uses Riverpod 3, go_router,
Dio, Freezed, Firebase platform services, Drift local data, and one verification
command.

> Implementation status: M0 is in progress. The readiness tooling and baseline
> hardening exist, but the repository is not release-ready until M1 reaches
> `READY` with real publisher resources and protected GitHub environments.

AI agents must read `AGENTS.md` and `docs/PRODUCT_SPEC.md` first.

## Contributor setup

```bash
brew install fvm
fvm install
make setup
make verify
```

The exact SDK is pinned in `.fvmrc`. Generated files and `pubspec.lock` are
committed.

## New-project gate

Publishing readiness runs before generated-project dependency installation,
branding, or feature work:

```bash
fvm dart run tool/release_readiness.dart init
fvm dart run tool/release_readiness.dart resume --interactive
fvm dart run tool/release_readiness.dart validate --live
fvm dart run tool/release_readiness.dart plan
```

The wizard collects shared, App Store, Google Play, Firebase, signing, metadata,
privacy, reviewer, and GitHub inputs. It never creates initial store app records
or stores credential values in `.env`. Local environment files contain
`file://` or `keychain://` references; credentials remain in external `0600`
files, the OS keychain, and protected GitHub environment secrets.

Project generation stays blocked until:

`DRAFT -> ANSWERED -> RESOURCES_VALIDATED -> GITHUB_CONFIGURED -> APPROVED -> READY`

## Commands

| Task | Command |
|---|---|
| Toolchain and manifest checks | `make doctor` |
| Readiness status | `make readiness` |
| Redacted GitHub mutation plan | `make readiness-plan` |
| Dependencies and code generation | `make setup` |
| Unit/widget/contract tests | `make test` |
| Compare goldens | `make goldens-check` |
| Intentionally regenerate goldens | `make goldens-update` |
| Definition of done | `make verify` |
| Run development app | `make run API_BASE_URL=http://localhost:8080` |

`make feature NAME=x` is the pre-M5 generator. It is intentionally not yet
AC-2 compliant and must not be presented as complete project scaffolding.

## Agent skills

The repository commits official Dart and Flutter skills under `.agents/skills`
and loads them through `opencode.json`. Restore exact GitHub-sourced skills with:

```bash
npx --yes skills@1.5.17 experimental_install
npx --yes @skills-hub-ai/cli restore
```

Installed sources:

- `flutter/agent-plugins`: Flutter workflows and UI/testing/routing skills.
- `dart-lang/skills`: Dart testing, analysis, CLI, FFI, and language skills.
- `flutter-dart-skills-flutter-adaptive-ui` v1.0.1: signed Adaptive UI skill.

Restart OpenCode after skill or `opencode.json` changes; configuration and
skills are loaded only at process startup.

## Architecture

```text
lib/features/<name>/
  domain/        pure entities and repository contracts
  data/          DTOs, remote/local sources, repository implementations
  application/   generated Riverpod controllers
  presentation/  localized adaptive UI
```

- The custom HTTPS API is authoritative.
- Firebase provides identity and platform services, not a second domain store.
- Drift is the local source of truth; writes use a durable outbox.
- Repositories return `Result<T>` and do not leak transport exceptions.
- Errors carry stable codes and are localized only in presentation.
- Navigation uses named routes.
- Secrets never enter Dart defines, `AppConfig`, source, logs, or app assets.

The existing Todos implementation is still the layering/test-style reference.
M2-M4 will replace its online-only behavior with the approved offline slice.

## Quality gates

`./tool/verify.sh` runs manifest validation, forbidden-material checks,
dependencies, l10n, codegen, formatting, analysis, tests, and coverage.

- Global handwritten line coverage: at least 90%.
- Auth/config/storage/sync coverage: at least 95%.
- Omitted executable Dart files count as uncovered.
- Security and release compilation run in dedicated pinned workflows.

## Milestones

Implementation follows `docs/PRODUCT_SPEC.md`: M0 contracts, M1 readiness, M2
walking skeleton, M3 foundations, M4 reference slice, M5 generators, M6 gates,
M7 release automation, and M8 qualification. Every milestone passes verification
before the next begins.

See `docs/NEW_PROJECT.md` for the fail-closed bootstrap sequence.
