# Contributing

## Setup

```bash
brew install fvm
fvm install
make setup
make verify
```

Use the exact Flutter version from `.fvmrc`; do not switch to `stable`.

## Scope and architecture

- Map changes to an approved `docs/PRODUCT_SPEC.md` milestone and acceptance ID.
- Preserve M0-M8 dependencies; do not implement later milestones around a
  failing earlier gate.
- Use `features/<name>/{domain,data,application,presentation}`.
- Keep domain framework-free and JSON in data DTOs.
- Use generated Riverpod providers, go_router named routes, the shared Dio
  client, Freezed, and json_serializable.
- Repositories return `Result<T>`; presentation localizes typed failures.
- The custom API is authoritative, Firebase provides platform services, and
  Drift owns local domain state.

The current Todos feature is a layering/test-pattern reference only. It is not
yet the offline/auth/sync reference promised by M2-M4.

## Secrets and configuration

Nonsecret environment values flow through `starter.yaml` and `AppConfig`.
Credential values never use Dart defines or `.env`. Use external permission-
restricted files, keychain references, and protected GitHub environment secrets.

Do not paste credentials, PII, private reviewer contacts, or raw provider errors
into issues or reviews.

## Generated artifacts

Run code generation after annotation or ARB changes. Commit `*.g.dart`,
`*.freezed.dart`, generated localization files, and `pubspec.lock` with their
sources.

## Tests

- Unit tests for domain, repositories, controllers, and tooling.
- Widget tests through the production theme/router/localization shell.
- Contract tests for API, storage, sync, and readiness boundaries.
- Integration tests for the walking skeleton.
- Accessibility/responsive/golden evidence for UI changes.

Do not delete assertions to make a build pass. The final gate is always:

```bash
./tool/verify.sh
```

## Reviews

Keep commits focused and use Conventional Commits. Complete the pull request
template with milestone/AC mapping, verification evidence, security/privacy
impact, generated artifacts, and any dedicated test results.
