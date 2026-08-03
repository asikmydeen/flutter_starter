# AGENTS.md — Operating Manual

> Directives for any AI coding agent working in this repo.
> Bootstrapping a NEW project from this template? See `docs/NEW_PROJECT.md`.

## The two gates

1. **Asked to build an app (or a substantial feature set)?** Do NOT start
   coding. Run the intake protocol in `docs/INTAKE.md` first: ask its
   questions (in batches, with defaults), write the answers to
   `docs/PRODUCT_SPEC.md`, get one approval, then build in the order the
   protocol defines. If `docs/PRODUCT_SPEC.md` already exists, read it
   before anything else — it is the source of truth. If it exists but the
   request contradicts it, reconcile the spec first.
2. **A task is done when `./tool/verify.sh` passes.** It runs deps → l10n →
   codegen → format → analyze → tests → coverage floor. CI runs the exact
   same script (`--ci` mode adds codegen-drift and format-drift failures).
   Never declare a task complete without running it.

Single small task on an existing app (bug fix, one endpoint, one screen
tweak)? Gate 1 doesn't apply — just mirror existing patterns and hit gate 2.

## Commands

| Task | Command |
|---|---|
| One-time setup after clone | `make setup` |
| Regenerate codegen (freezed/riverpod/json) | `make gen` |
| Regenerate l10n from ARB files | `make l10n` |
| Fast tests (no goldens) | `make test` |
| Regenerate golden screenshots | `make goldens` |
| **Full verification (definition of done)** | `make verify` or `./tool/verify.sh` |
| Scaffold a new feature | `make feature NAME=my_feature` |
| Run the app | `make run` (dev flavor) |

The SDK is pinned in `.fvmrc` and CI reads it from there. Use `fvm flutter`
if FVM is installed; the Makefile and verify.sh handle this automatically.

## Stack (do not substitute)

Riverpod 3 (`@riverpod` codegen only — no `StateNotifier`, no manual
providers for feature logic) · go_router · dio · freezed 3 + json_serializable ·
very_good_analysis · mocktail + http_mock_adapter for tests.

## How to add a feature

1. `make feature NAME=my_feature` — stamps the canonical layout with
   `TODO(agent)` markers and a passing test skeleton.
2. Fill in the markers. Mirror the reference feature `lib/features/todos/`
   for every pattern decision — it is the gold standard for all four layers.
3. `make gen`, add a route (`RouteNames` + `GoRoute` in
   `lib/core/router/app_router.dart`), add strings to
   `lib/l10n/arb/app_en.arb` + `make l10n`.
4. `./tool/verify.sh`.

## Architecture rules

- **Layers**: `features/<name>/{domain,data,application,presentation}`.
  Domain = pure entities + repository interfaces. Data = DTOs (own all JSON)
  + repository implementations. Application = `@riverpod` controllers.
  Presentation = screens/widgets.
- **Repositories never throw.** They return `Result<T>` (`lib/core/result/`).
  Catch with `on Exception`, map via `mapToAppException`. The closed error
  set lives in `lib/core/error/app_exception.dart` — extend it there, don't
  invent ad-hoc exceptions.
- **Controllers** rethrow failures via `result.valueOrThrow` so Riverpod
  exposes `AsyncError`; screens `switch` on `AsyncValue` and render all
  three states (see `todos_screen.dart`).
- **User-facing strings** go in `lib/l10n/arb/app_en.arb`, never inline.
- **Navigation** only via `context.goNamed(RouteNames.x)` — no raw paths.
- **Env values** only via `AppConfig` — never read `String.fromEnvironment`
  elsewhere, never hardcode URLs or secrets.
- **Errors at the top**: global handlers live in `lib/bootstrap.dart` only.

## Codegen rules

- After editing ANY file with `@riverpod`, `@freezed`, or json annotations:
  `make gen`. Not optional — CI fails on drift.
- Generated files (`*.g.dart`, `*.freezed.dart`, `lib/l10n/gen/`) are
  COMMITTED. Commit them together with their sources.
- json_serializable runs with `checked: true` (see `build.yaml`): bad
  payloads throw `CheckedFromJsonException` (an Exception), which
  `mapToAppException` turns into `ParsingException`. Don't change this.

## Testing patterns (copy these, don't invent)

| Layer | Reference test | Technique |
|---|---|---|
| Data | `test/features/todos/data/api_todos_repository_test.dart` | Mock HTTP with `http_mock_adapter` |
| Application | `test/features/todos/application/todos_controller_test.dart` | `mocktail` mock of the repo interface + `ProviderContainer` |
| Presentation | `test/features/todos/presentation/todos_screen_test.dart` | `tester.pumpApp(...)` with provider overrides |
| Visual | `test/goldens/home_screen_golden_test.dart` | Golden, tagged `golden` |

- Always pump screens with `tester.pumpApp` from `test/helpers/helpers.dart`.
- Test names: `should <expected behavior> when <condition>`.
- Golden tests are excluded from default runs and CI (cross-platform
  rasterization drift). Regenerate intentionally: `make goldens`.

## Known gotchas (learned the hard way — do not rediscover)

1. **Riverpod 3 auto-retries failed providers** with backoff. Error-path
   tests hang unless the container/scope sets `retry: (_, _) => null`.
   `pumpApp` and the test templates already do this.
2. **Generated providers are autoDispose.** In `ProviderContainer` tests,
   hold a listener (`container.listen(...)`) or the provider is disposed
   mid-load with "disposed during loading state". Subscribe AFTER stubbing
   mocks — listening triggers the first build.
3. **`Override` moved to `package:flutter_riverpod/misc.dart`** in
   Riverpod 3. If `List<Override>` won't resolve, that import is missing.
4. **freezed 3 requires `abstract`/`sealed`** on annotated classes
   (`abstract class Todo with _$Todo`).
5. **`AppConfig.instance` before `init()` throws StateError.** In tests,
   call `setUpTestConfig()` from `test/helpers/` if config is touched.
6. **build_runner conflicts**: always use `--delete-conflicting-outputs`
   (the Makefile does).
7. **iOS pod failures**: `cd ios && pod install --repo-update`. Gradle
   heap: bump `org.gradle.jvmargs` in `android/gradle.properties`.
8. **Hot reload does not apply codegen changes** — rerun `make gen`, then
   restart.

## Environments

`--dart-define=ENV=dev|staging|prod`, read once in `bootstrap()` into
`AppConfig`. Unknown values throw at startup by design. Default is `dev`.

## MCP

The Dart SDK ships an MCP server that gives agents structured access to the
analyzer, test runner, and pub. Prefer it over parsing CLI text when your
runtime supports MCP — see `.mcp.json` at the repo root:

```bash
dart mcp-server
```

## Scope discipline

- Match existing patterns before inventing new ones. Deviating from a
  pattern in this file requires calling it out and getting approval first.
- Minimal changes; no drive-by refactors; flag extra work, don't do it.
- Never commit secrets. `.env*`, keystores, `key.properties` are gitignored.
