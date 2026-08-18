# New Project Bootstrap

No generated project starts until the approved product spec exists and release
readiness is `READY` for the current manifest digest.

## Contributor preflight

@@@task
Install FVM, run `fvm install`, and make `fvm flutter doctor -v` clean for the
required iOS and Android toolchains.
@@@

@@@task
Run `make setup` and `make verify` in the template checkout. This hydrates the
contributor repository; it does not generate an app.
@@@

## Publishing readiness

@@@task
Run `fvm dart run tool/release_readiness.dart init` in an interactive terminal.
Answer every shared, Apple, Google Play, Firebase, metadata, signing, privacy,
reviewer, and GitHub question or record an explicit `notApplicable` answer where
the schema permits it.
@@@

@@@task
Create the initial App Store Connect and Google Play Console app records
manually. The tool never creates them. Resume the wizard after recording their
IDs.
@@@

@@@task
Move one-time `.p8`, `.p12`, provisioning, keystore, Firebase, and private
metadata files to the external `0700` credential directory. Restrict files to
`0600`; keep passwords in the keychain. `.env.release.local` stores references,
not values.
@@@

@@@task
Run live validation, inspect the redacted plan, then explicitly confirm GitHub
environment provisioning. M1 creates and validates `release-internal` and
`release-production`; M7 may only consume them.
@@@

## Generated project

Project bootstrap implementation lands in M5. It will consume `starter.yaml`,
assert readiness, stage output atomically, apply identity/branding/environment
configuration, run code generation, verify, and compile both platforms before
publishing the destination.

Until M5 is complete, manual renaming or `make feature` does not constitute a
conformant generated project.

## Fixed technical decisions

- iOS 13.0 or newer.
- Android API 24 minimum and API 36 target.
- Riverpod-only feature logic.
- Custom HTTPS API authoritative.
- Firebase identity/platform services.
- Drift local source of truth with durable outbox.
- 90% global and 95% critical-module coverage.
- No secrets in source, Dart defines, `AppConfig`, `.env`, logs, or assets.
