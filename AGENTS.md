# AGENTS.md — Flutter Project Build Guide

> Directives for any AI coding agent (Claude Code, Cursor, Kiro, Copilot, etc.) working in a Flutter repo.
> Follow phases **in order** — each unblocks the next. Check off items as you complete them.
> This file is portable: drop it into any Flutter repo and hand it to an agent.

## Golden rules

- **Match ceremony to complexity.** A 5-screen app does NOT need full Clean Architecture. Don't over-engineer.
- **Never hardcode secrets or environment values.** Use `--dart-define` and `AppConfig`.
- **Codegen is not optional.** After editing any `freezed`, `json_serializable`, or `riverpod_generator` annotated file, run `dart run build_runner build --delete-conflicting-outputs`.
- **Lints and tests must pass before every commit.** `flutter analyze` clean + `flutter test` green.
- **Prefer the modern default stack** (below) unless the repo already committed to another. Do not mix state-management libraries.
- **One feature = one folder** under `lib/features/`, with `data / domain / application / presentation` layers.

## Modern default stack

| Concern | Package |
|---|---|
| State | `flutter_riverpod` + `riverpod_generator` |
| Navigation | `go_router` |
| Networking | `dio` |
| Models | `freezed` + `json_serializable` |
| Storage | `isar` / `drift` / `shared_preferences` |
| DI | `get_it` + `injectable`, or Riverpod providers |
| Codegen | `build_runner` |
| Lints | `very_good_analysis` |

---

## Phase 0 — Environment

- [ ] Ensure **FVM** is installed and the SDK pinned (`.fvmrc` present); if missing, run `fvm use stable`.
- [ ] Run `flutter doctor` and resolve every ✗ (Xcode + CocoaPods, Android SDK, licenses).
- [ ] Confirm an iOS simulator AND an Android emulator are available.

## Phase 1 — Scaffold from a blueprint

- [ ] Prefer **Very Good CLI** over bare `flutter create`: `very_good create flutter_app <name>`.
- [ ] Set reverse-domain bundle/application IDs (e.g. `com.company.app`).
- [ ] `git init` and make the first commit before writing feature code.

## Phase 2 — Structure & config

- [ ] Adopt **feature-first + layered** structure: `core/` (config, theme, router, network) + `features/<feature>/{data,domain,application,presentation}`.
- [ ] Set up **flavors**: dev / staging / prod.
- [ ] Wire env config via `--dart-define=ENV=...` read through a single `AppConfig` class.
- [ ] Configure app name, launcher icon (`flutter_launcher_icons`), splash (`flutter_native_splash`).
- [ ] Add type-safe asset handling (`flutter_gen`) and declare `assets/` in `pubspec.yaml`.

## Phase 3 — Core dependencies

- [ ] Add the modern default stack (table above) to `pubspec.yaml`.
- [ ] Run `flutter pub get`.
- [ ] Establish a codegen habit: `dart run build_runner watch --delete-conflicting-outputs` during dev.

## Phase 4 — Quality guardrails (do NOW, not later)

- [ ] Strict lints: `include: package:very_good_analysis/analysis_options.yaml` in `analysis_options.yaml`; exclude `*.g.dart` / `*.freezed.dart`.
- [ ] Testing pyramid: unit (logic) → widget (UI) → integration (`patrol` for native flows).
- [ ] Pre-commit hook (`lefthook` or similar): `dart format` + `flutter analyze`.
- [ ] CI from commit #1: GitHub Actions running `flutter analyze` + `flutter test` on every PR (see `.github/workflows/ci.yml`).

## Phase 5 — App skeleton before features

- [ ] Central **theme** (light/dark via `ColorScheme.fromSeed`, typography).
- [ ] **Router** with a shell route + not-found handling.
- [ ] Global **error handling** + logging (`logger` / `talker`).
- [ ] App-wide **localization** (l10n) scaffolding, even if single-language now.
- [ ] A `Result`/`Either` return type for the data layer.

## Phase 6 — Ship readiness

- [ ] `flutter build appbundle` (Android) and `flutter build ipa` (iOS) both succeed.
- [ ] Signing configured: Android keystore + iOS certs/provisioning.
- [ ] CI/CD for store delivery (**Codemagic** or **Fastlane**).
- [ ] Crash/analytics wired (Firebase Crashlytics / Sentry).
- [ ] Store assets ready: privacy policy, screenshots, descriptions.

---

## Definition of done (for any feature)

1. Code compiles; `flutter analyze` is clean.
2. Codegen artifacts regenerated and committed (or gitignored consistently).
3. Unit + widget tests cover the new logic and pass.
4. No hardcoded secrets; env-dependent values go through `AppConfig`.
5. New feature follows the `features/<name>/{data,domain,application,presentation}` layout.

## The 20% that gives 80% of the value

Blueprint scaffold (Phase 1) + feature-first + Riverpod (Phases 2–3) + lints & CI from day one (Phase 4). Skip those and every later phase gets harder.
