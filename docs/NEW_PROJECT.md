# New Project Checklist

> Phase checklist for standing up a NEW project from this template.
> For day-to-day work in this repo, see **AGENTS.md** — that is the
> operating manual. This file is only for project bootstrap.

## Golden rules

- **Match ceremony to complexity.** A 5-screen app does NOT need full Clean Architecture. Don't over-engineer.
- **Never hardcode secrets or environment values.** Use `--dart-define` and `AppConfig`.
- **Lints and tests must pass before every commit.** `./tool/verify.sh` green.
- **Do not mix state-management libraries.** This template is Riverpod-only.

## Phase 0 — Environment

- [ ] Install FVM; the SDK is pinned in `.fvmrc`. Run `fvm install` then `fvm use`.
- [ ] Run `flutter doctor` and resolve every ✗ (Xcode + CocoaPods, Android SDK, licenses).
- [ ] Confirm an iOS simulator AND an Android emulator are available.

## Phase 1 — Identity

- [ ] Rename the package: `name:` in `pubspec.yaml`, then global-replace `package:flutter_starter/` imports.
- [ ] Set reverse-domain bundle/application IDs (template ships `com.example.flutter_starter`):
      Android: `android/app/build.gradle.kts` (`applicationId`), iOS: Xcode Runner target.
- [ ] Set real API base URLs per environment in `lib/core/config/app_config.dart`.
- [ ] Make the first commit before writing feature code.

## Phase 2 — Branding

- [ ] App display name (AndroidManifest / Info.plist).
- [ ] Launcher icon: configure `flutter_launcher_icons` in pubspec, run it.
- [ ] Splash screen: configure `flutter_native_splash`, run it.

## Phase 3 — Quality guardrails (already wired — just activate)

- [ ] Install pre-commit hooks: `lefthook install`.
- [ ] Push to GitHub — CI (`.github/workflows/ci.yml`) runs verify + Android build + security scans on every PR.
- [ ] Set `MIN_COVERAGE` in `tool/verify.sh` to the team's floor (default 70).

## Phase 4 — Ship readiness

- [ ] `flutter build appbundle --dart-define=ENV=prod` (Android) and
      `flutter build ipa --dart-define=ENV=prod` (iOS) both succeed.
- [ ] Signing configured: Android keystore (`key.properties` is gitignored) + iOS certs/provisioning.
- [ ] CI/CD for store delivery (Codemagic or Fastlane).
- [ ] Crash reporting wired (Crashlytics/Sentry) — forward from the three
      handlers in `lib/bootstrap.dart`, nowhere else.
- [ ] Store assets: privacy policy, screenshots, descriptions.

## Definition of done (every feature)

Run `./tool/verify.sh`. It encodes all of it: codegen fresh, format clean,
analyze clean, tests green, coverage above the floor.
