# Project Intel

Last reviewed: 2026-08-17

## Authority and state

- `docs/PRODUCT_SPEC.md` is approved and authoritative.
- The detailed deep-interview spec is supporting rationale.
- Current milestone: M0 in progress. M1-M8 are not started.
- Existing code is a brownfield baseline, not proof of target compliance.
- Generated-project work remains blocked until M1 readiness reaches `READY`.

## Stack and architecture

- Flutter 3.44.8 through FVM; Dart 3.12.2.
- Riverpod 3 code generation, go_router, Dio, Freezed 3,
  json_serializable, very_good_analysis, Mocktail, and http_mock_adapter.
- Features use `domain/data/application/presentation`.
- Repositories return `Result<T>` and do not expose transport failures.
- Navigation uses named routes; user-facing strings use ARB localization.
- The custom HTTPS API is authoritative, Firebase supplies identity/platform
  services, and Drift is the local source of truth.
- Offline writes use a durable outbox with idempotency and version conflicts.

## Commands

- `make setup`: dependencies, localization, and code generation.
- `make gen`: Riverpod/Freezed/JSON generation.
- `make l10n`: localization generation.
- `make test`: fast tests excluding goldens.
- `make goldens-check`: compare golden images.
- `make goldens-update`: intentional golden regeneration.
- `make verify` or `./tool/verify.sh`: definition of done.
- `make feature NAME=x`: incomplete pre-spec generator until M5 replaces it.

## Patterns

- Mirror `lib/features/todos/` only for layer boundaries, `Result`, Riverpod
  `AsyncValue` handling, and test techniques.
- DTOs own JSON; domain entities remain framework-free.
- Controllers convert repository failures into Riverpod `AsyncError`.
- Widget tests use provider overrides and the production theme/router/l10n.
- Generated files are committed with annotated sources.
- Secrets never enter Dart defines, `AppConfig`, `.env*`, logs, or assets.
  `.env.release.local` may contain nonsecret values and references only.

## Gotchas and baseline defects

- Riverpod 3 retries failures unless tests set `retry: (_, _) => null`.
- Auto-dispose providers need a listener after mocks are stubbed.
- `Override` comes from `package:flutter_riverpod/misc.dart`.
- Freezed 3 annotated classes must be abstract or sealed.
- Initialize `AppConfig` in tests before config-dependent providers.
- Always run build_runner through the project command.
- Collection casts can throw `TypeError` outside `on Exception` handlers.
- Current Dio logging exposes bodies and must not be copied.
- Baseline coverage is 78.2%; target is 90% global and 95% for critical code.
- Current Android release signing uses the debug key.
- Current CI dependency scanning is advisory/broken and actions are not pinned.
- Flutter 3.44.8 requires Android API 24; the approved spec reflects this.
