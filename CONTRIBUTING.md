# Contributing

Thanks for contributing! This guide keeps the codebase consistent and easy to work in.

## Prerequisites

- **FVM** with the pinned SDK (`fvm use stable` — see `.fvmrc`)
- `flutter doctor` clean (Xcode + CocoaPods, Android SDK, licenses)
- An iOS simulator and an Android emulator available

## Getting started

```bash
fvm flutter pub get
dart run build_runner build --delete-conflicting-outputs   # codegen
fvm flutter run --dart-define=ENV=dev

```

## Branching & commits

- Branch from `main`: `feat/<short-name>`, `fix/<short-name>`, `chore/<short-name>`.
- Use [Conventional Commits](https://www.conventionalcommits.org/):- `feat: add auth login screen`
- `fix: prevent counter from going negative`
- `chore: bump go_router to 14.2`
- `test: cover counter controller edge cases`
- `docs: update README quick start`
- Keep commits focused and atomic. Rebase before opening a PR.

## Project structure

Follow **feature-first + layered**. One folder per feature under `lib/features/`:

```
lib/features/<feature>/
├── data/          # repositories, data sources, DTOs
├── domain/        # entities, use-cases, repo interfaces
├── application/   # controllers / state (Riverpod)
└── presentation/  # screens + widgets

```

Cross-cutting concerns live in `lib/core/` (config, theme, router, network).

## Coding standards

- **State:** Riverpod. Do not introduce a second state-management library.
- **Navigation:** go_router only.
- **Models:** `freezed` + `json_serializable` — never hand-write `copyWith`/`fromJson`.
- **Networking:** the shared `dio` client provider in `core/network/`.
- **No hardcoded secrets or env values.** Route everything through `AppConfig` + `--dart-define`.
- After editing annotated files, regenerate: `dart run build_runner build --delete-conflicting-outputs`.

## Before you push

```bash
dart format .
fvm flutter analyze     # must be clean
fvm flutter test        # must be green

```

CI runs the same checks on every PR (`.github/workflows/ci.yml`). PRs that fail `analyze`, `format`, or `test` will not be merged.

## Testing

Follow the testing pyramid:

1. **Unit** — business logic (controllers, use-cases, repositories).
2. **Widget** — UI behavior for screens/widgets.
3. **Integration** — critical end-to-end flows (`patrol` for native interactions).

New logic must ship with tests. Bug fixes should include a regression test.

## Definition of done

1. Code compiles; `flutter analyze` is clean.
2. Codegen artifacts regenerated (and gitignored consistently).
3. Unit + widget tests cover new logic and pass.
4. No hardcoded secrets; env values via `AppConfig`.
5. Feature follows the `data / domain / application / presentation` layout.
6. PR description filled out (see the pull request template).

## Opening a pull request

- Fill out the PR template completely.
- Link the related issue.
- Keep PRs small and reviewable. Split large work into stacked PRs when possible.

