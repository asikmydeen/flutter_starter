# Deep Interview Spec: Production Flutter Starter

## Metadata

| Field | Value |
|---|---|
| Interview ID | `77379CBA-A30F-4CAE-BB5B-980D2F16D28B` |
| Rounds | 5 |
| Final ambiguity | 9% |
| Type | Brownfield template enhancement |
| Generated | 2026-08-17 |
| Threshold | 20% |
| Status | PASSED, incorporated into approved `docs/PRODUCT_SPEC.md` |

## Clarity breakdown

| Dimension | Score | Weight | Weighted |
|---|---:|---:|---:|
| Goal clarity | 0.92 | 0.35 | 0.3220 |
| Constraint clarity | 0.91 | 0.25 | 0.2275 |
| Success criteria | 0.92 | 0.25 | 0.2300 |
| Context clarity | 0.87 | 0.15 | 0.1305 |
| **Total clarity** |  |  | **0.9100** |
| **Ambiguity** |  |  | **0.0900** |

## Goal

Turn the existing Flutter starter into an opinionated production platform that
includes API security, enterprise-ready identity boundaries, offline-first
data, Firebase-backed platform services, adaptive design, comprehensive tests,
quality gates, complete scaffolding, and internal release automation by
default.

Before project generation, a mandatory release-readiness wizard must collect
and validate App Store, Google Play, Firebase, signing, store metadata, local
secret-storage, and GitHub release-environment inputs.

The implementation must improve speed without creating alternative stacks:
developers retain one architecture, one database strategy, one synchronization
model, one verification entry point, and one default vendor integration.

## Constraints

- Preserve Riverpod 3 code generation, go_router, Dio, Freezed 3,
  json_serializable, very_good_analysis, Mocktail, and http_mock_adapter.
- Preserve `Result<T>` repository boundaries and named navigation.
- Keep the custom HTTPS API authoritative for domain data.
- Use Drift/SQLite as the single local domain database.
- Include Firebase Auth by default, Identity Platform-compatible enterprise
  adapters, App Check, Crashlytics, Analytics, Performance Monitoring,
  Messaging, and Remote Config.
- Require real vendor configuration for runtime/release builds; use fakes and
  emulators for deterministic tests and PR CI.
- Include every capability in the generated app. Interfaces exist for testing
  and containment, not as user-facing capability packs.
- Keep secrets outside source, Dart defines, and compiled client assets.
- Keep local verification deterministic and platform-independent; device,
  release, golden, and benchmark suites run in dedicated workflows.
- Implement one milestone at a time and pass `./tool/verify.sh` before moving
  forward.
- Block project generation until `config/release_readiness.json` is approved
  and `READY` for the current `config/release_readiness.json` digest. Readiness follows
  `DRAFT -> ANSWERED -> RESOURCES_VALIDATED -> GITHUB_CONFIGURED -> APPROVED -> READY`.
  No skip or force path exists.
- Store nonsecret configuration and credential references in
  `.env.release.local`; store actual secrets in restricted external files, the
  OS keychain, and protected GitHub environment secrets.

## Non-goals

- A framework rewrite or support for arbitrary technical stacks.
- Direct Firestore access as the primary generic domain-data pattern.
- Automatic production infrastructure or account creation.
- Generic automatic resolution of business conflicts.
- Regulatory certification.
- Public app-store approval automation.
- Automatic legal enrollment, agreement acceptance, tax/banking submission,
  identity verification, or recovery of one-time-download private keys.
- Web and desktop platform support in this implementation scope.

## Acceptance criteria

| ID | Verification |
|---|---|
| DI-1 | Three clean trials meet the 60-minute clone-to-signed-internal-release target on the documented machine profile. |
| DI-2 | Twenty warm-cache scaffold trials have p95 duration at or below 300 seconds and produce no TODO markers or verification drift. |
| DI-3 | Global handwritten line coverage is at least 90%; critical auth/config/storage/sync modules are at least 95%. |
| DI-4 | Local-first reference mutations survive restart, replay idempotently, preserve conflicts, and converge within 30 seconds after reconnection. |
| DI-5 | Security, dependency-license, accessibility, performance, migration, Android release, and iOS release-compilation gates are blocking. |
| DI-6 | PR CI uses no live Firebase project, production credential, signing secret, or external backend. |
| DI-7 | Runtime release startup rejects missing or mismatched vendor/environment configuration with a localized actionable error. |
| DI-8 | All user-facing strings, including errors and capability states, are localized. |
| DI-9 | Project generation is impossible until `config/release_readiness.json` is approved and `READY` for the current `config/release_readiness.json` digest. |
| DI-10 | Intake covers every applicable Apple, Google Play, Firebase, signing, metadata, privacy, reviewer, and CI field, with explicit not-applicable decisions. |
| DI-11 | Private credentials never appear in `.env*`, source control, process arguments, state, logs, reports, or generated client assets. |
| DI-12 | The wizard resumes after interruption and blocks safely on missing external resources without creating project files. |
| DI-13 | Protected GitHub release environments are configured and validated before generation; pull requests, forks, Dependabot, and untrusted workflow triggers cannot access them. |
| DI-14 | A redacted dry-run performs no filesystem, keychain, configuration, GitHub, provider, build, upload, or store mutation. |
| DI-15 | Live validation proves Apple, Google Play, Firebase, signing, and GitHub resources/API access exist, match expected identifiers, are unexpired, and have least privilege, including complete OIDC trust restrictions. |
| DI-16 | Rotation validates the replacement before switching GitHub and leaves the active credential unchanged on failure. Tooling never revokes automatically, but records a human revocation due within 24 hours and verifies completion. |
| DI-17 | Tooling never creates an initial App Store Connect or Google Play Console app record and resumes only after validating human-supplied record IDs. |
| DI-18 | Dependency-license reports contain no denied or unknown license without an owned, expiring waiver. |
| DI-19 | Nonpublic legal identities, review contacts, tester lists, and personal data never enter source or `.env*`; they use restricted private metadata storage and protected environment secrets only when CI requires them. |
| DI-20 | High/critical dependency vulnerabilities and denied/unknown licenses are waivable only with an owner and expiry. Leaked secrets, unredacted sensitive logs, debug release signing, and generated-code drift are never waivable. |

## Assumptions exposed and resolved

| Assumption | Challenge | Resolution |
|---|---|---|
| One starter can optimize for four app categories. | Each category can demand conflicting defaults. | Use one maximal mobile profile with one internal architecture and all foundations wired. |
| Everything enabled is faster for developers. | More dependencies and setup can slow bootstrap. | Preselect vendors, automate configuration, validate prerequisites, and benchmark the workflow. |
| Firebase and an API can both own data. | Dual authority creates unsafe synchronization. | The custom API owns domain data; Firebase supplies identity and platform services. |
| Vendor defaults can run without setup. | Production integrations require credentials and policies. | Runtime/release builds fail closed; tests use fakes or emulators. |
| Analytics can always start immediately. | Consent may be legally required. | Include analytics by default but gate collection through consent state. |
| A 60-minute release includes all machine setup. | SDK downloads and account provisioning are not stable benchmarks. | Start on a documented pre-provisioned machine with credentials available. |
| Release credentials can be collected near launch. | Late collection exposes immutable IDs, missing accounts, and signing blockers after development. | Require publishing readiness before project generation. |
| All requested secrets belong in `.env`. | Plaintext environment files expose one-time keys, passwords, and service-account credentials. | `.env.release.local` stores references only; restricted files, keychain entries, and GitHub encrypted secrets hold credentials. |

## Technical context

The repository already has the right architectural spine:

- `lib/features/todos/` demonstrates domain, data, application, and
  presentation layers.
- `lib/core/result/` and `lib/core/error/` provide typed failure flow.
- `lib/core/network/dio_client.dart` centralizes HTTP creation.
- `lib/core/router/app_router.dart` centralizes named routes.
- `tool/new_feature.dart` provides an incomplete but useful generator base.
- `tool/verify.sh` and `.github/workflows/ci.yml` provide the existing quality
  and CI entry points.

Known baseline defects must be fixed before adding foundations:

- Release networking/signing are not production-ready.
- Staging/development body logging can expose sensitive data.
- The repository parser can throw a `TypeError` outside its `Exception` catch.
- Error messages are hardcoded rather than localized.
- Tests do not use the production router/theme path.
- Coverage is 70%, security findings are advisory, and feature generation
  omits routes, localization, and most test layers.

## Planned architecture

| Area | Decision |
|---|---|
| Configuration | Checked-in nonsecret project manifest plus secret/signing preflight |
| API configuration | Separate `dev`, `staging`, and `prod` URLs in `starter.yaml`; OpenAPI at `docs/openapi/reference_api.yaml` |
| Identity | Firebase Auth email/password, Google, and Apple behind domain interfaces; `user`/`admin` reference claims |
| API security | Firebase ID token, App Check, correlation ID, redaction, bounded retry |
| Persistence | Drift/SQLite with forward-only tested migrations |
| Offline writes | Transactional local mutation plus durable outbox |
| Synchronization | At-least-once delivery, idempotency keys, versions, tombstones, retry |
| Conflict handling | Automatic disjoint merge; durable base/local/remote conflict otherwise |
| Observability | Structured logs plus Firebase crash, analytics, and performance adapters |
| Runtime control | Typed Remote Config defaults, last-known-good state, and kill switches |
| Presentation | Tokenized Material 3, adaptive navigation, semantics, RTL, text scaling |
| Platforms | iOS 13.0 or later; Android API 24 or later, targeting API 36 for release |
| Verification | Fast local gate plus dedicated integration, golden, security, benchmark, and release jobs |
| Release intake | Resumable fail-closed wizard with schema, redacted state, dry-run, and live validation |
| Secret placement | External `0600` files, OS keychain, GitHub protected environments, reference-only `.env.release.local` |

## Pre-project publishing intake

The wizard runs before project generation and uses a versioned provider schema
so changes to Apple or Google requirements invalidate stale readiness. It asks
all shared questions plus platform-conditional questions and requires explicit
`not applicable` answers rather than silently omitting fields.

### Shared collection

- Legal app and publisher identities, organization namespace, support contacts,
  locale, version/build policy, monetization, countries, and release strategy.
- Listing names/descriptions/categories, copyright, support/privacy/deletion/
  marketing URLs, review contacts, demo credentials, reviewer instructions,
  media assets, translations, and release-note sources.
- Data collection/sharing, consent, ads, age/audience, content rights,
  encryption/export compliance, restricted permissions, and deletion
  declarations. Tooling records but never invents legal answers.
- Public store contacts may use the nonsecret manifest. Legal identities,
  private review contacts, tester lists, and nonpublic personal data use a
  separate external `0600` private metadata file and never source or `.env*`.

### Apple collection

- Developer membership account type/status, Team ID, roles, agreement status,
  bundle IDs, App Store Connect app record ID, immutable SKU, localization,
  pricing, countries, TestFlight, release mode, DSA status, age rating, and
  content rights.
- App Store Connect API `.p8`, key ID, issuer ID, key type, role, creation date,
  rotation owner, and one-time-download backup confirmation.
- Distribution signing strategy, certificate/profile details, `.p12` and
  password where manual signing applies, entitlements, and export options.
- Separate APNs `.p8`, key ID, Team ID, environment, and topics when push is
  enabled.
- `GoogleService-Info.plist`, Firebase app mapping, `PrivacyInfo.xcprivacy`,
  required-reason API declarations, export compliance, App Privacy responses,
  icons, screenshots/previews, listing copy, URLs, review contacts, demo
  credentials, and review instructions.

### Google Play collection

- Google Play developer account type/status, verification status, developer ID,
  verified legal/public contacts, agreement status, application ID, Google Play
  Console app record, language, app/game and free/paid choices, countries,
  tracks, testers, category/tags, and managed-publishing policy.
- Play App Signing status and fingerprints, upload keystore, alias, passwords,
  certificate fingerprint/expiry, backup owner, and key-reset status.
- Google Cloud project, Play Developer API enabled/status, least-privilege
  publishing identity, and OIDC/Workload Identity Federation configuration.
  Service-account JSON is allowed only through an approved exception with an
  owner, rationale, expiry of at most 90 days, and rotation plan.
- `google-services.json`, Firebase app mapping, App Check, and production
  signing fingerprints.
- Data Safety, privacy/account deletion, ads, audience/Families, content rating,
  app access, reviewer credentials, restricted permissions, conditional policy
  declarations, store listing copy, support contacts, icon, feature graphic,
  screenshots/video, pricing, countries, and release notes.

### Placement and validation

| Material | Local destination | GitHub destination |
|---|---|---|
| Nonsecret IDs and policy | `config/release_readiness.json` or `.env.release.local` | environment/repository variables |
| Credential file references | `.env.release.local` | not uploaded |
| Apple `.p8`, `.p12`, profiles | external user-owned `0700` directory and `0600` files | protected environment secrets |
| Android upload keystore/passwords | external `0700` directory, `0600` file, and keychain | protected environment secrets |
| Google publishing identity | OS/cloud identity configuration | OIDC/WIF variables; JSON secret only as fallback |
| Firebase client configs | environment-isolated external files | protected environment variables/secrets |
| Private legal/review/tester metadata | external `0600` private metadata file | protected environment secret only when CI needs it |
| Tax, banking, identity, 2FA | human/provider systems only | never stored |

The wizard verifies identifiers, file permissions, certificate/profile
matching, expiry, Firebase mappings, Apple/Google Play API access, store-record
IDs, `gh` authentication, repository ownership, `release-internal` and
`release-production`, reviewers, protected refs, least-privilege workflow
permissions, secret-name presence, full-SHA action pinning, and OIDC trust
restrictions for organization/repository IDs, environment, ref/tag, workflow,
subject, and audience. GitHub writes
require one redacted-plan confirmation; secret values stream through standard
input and never process arguments or persisted output.

Dry-run performs no filesystem, keychain, configuration, GitHub, provider,
build, upload, or store mutation and redacts raw, encoded, escaped, and derived
secret forms. Rotation validates replacement access, identifiers, expiry, and
privileges before switching. Failure leaves the active GitHub secret unchanged.
Tooling never revokes automatically; it records a mandatory human revocation
due within 24 hours and verifies completion.

Allowed live mutations are limited to redacted local state/reference config,
secure external-file/keychain placement, authorized Android upload-key and
derived-asset generation, and GitHub protected-environment/variable/secret
provisioning. Apple, Google Play, and Firebase operations otherwise remain
read-only validation and configuration retrieval.

The wizard never creates initial App Store Connect or Google Play Console app
records, accounts, agreements, tax/banking records, or identity verification.
Missing human-owned resources save a redacted checkpoint, link the exact
official action, enter `BLOCKED_EXTERNAL_RESOURCE`, and resume only after the
human-supplied resource is validated.

## Verification matrix

| Gate | Local verify | PR CI | Scheduled/release |
|---|---|---|---|
| Format, analysis, codegen drift | yes | yes | yes |
| Unit/widget/contract tests | yes | yes | yes |
| 90% coverage | yes | yes | yes |
| Secret, dependency, license, log-redaction scans | selected | yes | yes |
| Firebase rules/emulator tests | no | yes | yes |
| Android integration tests | no | affected changes | yes |
| Accessibility and responsive tests | yes | yes | yes |
| Golden tests | explicit | UI changes | yes |
| Performance benchmarks | no | regression smoke only | fixed-device blocking |
| Android release artifact | no | compile/preflight | signed internal distribution |
| iOS release build | no | `--no-codesign` | signed internal distribution |
| Bootstrap/scaffold timing | targeted smoke | correctness | repeated benchmark |
| Release-readiness schema, redaction, and forbidden material | yes | yes | yes |
| Dry-run no-mutation contract | yes | yes | yes |
| Apple/Google Play/Firebase/signing/GitHub live validation | explicit | M1 protected workflow | before generation and release |
| Credential-rotation safety | contract test | protected workflow | rotation drill |

## Milestone boundaries

| Milestone | Dependency | Required proof |
|---|---|---|
| M0 Contracts and baseline | none | ADRs, manifest/OpenAPI schemas, benchmarks, license policy, bug fixes, current verify passes |
| M1 Publishing readiness | M0 | Wizard creates/configures/validates both protected GitHub environments; provider and resume tests pass |
| M2 Walking skeleton | M1 | Minimal auth/API/Todo persistence/offline sync/diagnostic path passes first-demo approval |
| M3 Production/offline foundations | M2 | Hardened auth/network/observability/migration/outbox/retry/conflict contracts pass |
| M4 Reference slice completion | M3 | Complete offline Todos, roles, deep links, push, privacy, and diagnostics pass integration tests |
| M5 Generators | M1, M4 | Readiness assertion and the DI-2 20-run scaffold benchmark pass |
| M6 Quality and release gates | M1-M5 | Coverage, a11y, security, licenses, performance, integration, and release policy block correctly |
| M7 Release automation | M6 | Only consumes M1 environments; signed artifacts, symbols, provenance, and rollback metadata are retained |
| M8 Qualification | M7 | Three readiness-to-release trials and the DI-2 scaffold benchmark pass |

## Ontology (key entities)

| Entity | Type | Fields | Relationships |
|---|---|---|---|
| FlutterStarterTemplate | Artifact | stack, capabilities, targets, verification | satisfies OptimizationTarget; governed by DeliveryStrategy |
| OptimizationTarget | Goal set | API-backed, enterprise, offline-first, reusable | selected by UserRequirement |
| UserRequirement | Specification | all targets, all capabilities, vendor defaults | defines DeliveryStrategy and AcceptanceCriterion |
| DeliveryStrategy | Strategy | maximal default, milestone delivery, fail-closed config | configures FlutterStarterTemplate |
| VendorConfiguration | Strategy | Firebase projects, credentials, emulators, consent | supplies platform services |
| QualityGate | Constraint | coverage, security, accessibility, performance, release | verifies AcceptanceCriterion |
| TimeConstraint | Constraint | 60-minute bootstrap, 5-minute scaffold | bounds developer workflows |
| Gap | Tracking entity | area, severity, milestone, evidence | closed by implementation tasks |
| AcceptanceCriterion | Success metric | threshold, environment, evidence | evaluated by QualityGate |
| PublishingWizard | Workflow | questions, state, provider checks, destinations | gates FlutterStarterTemplate generation |
| SecretManagementStrategy | Policy | classification, references, permissions, redaction | governs PlatformCredential placement |
| PlatformCredential | Secret artifact | provider, purpose, fingerprint, expiry, reference | consumed by GitHubSecretsProvisioning |
| GitHubSecretsProvisioning | Workflow | auth, repository ownership, named environments, reviewers, protected refs, permissions, variables, secrets, full-SHA pins | configures DeliveryStrategy |
| BlockAndResumeWorkflow | State machine | blocked reason, checkpoint, stale checks | controls PublishingWizard |
| StoreMetadata | Configuration | listing, privacy, rating, review, pricing, availability | supplied to Apple and Google stores |

## Ontology convergence

| Round | Entity count | New | Changed | Stable | Stability ratio |
|---|---:|---:|---:|---:|---:|
| 1 | 4 | 4 | 0 | 0 | N/A |
| 2 | 5 | 1 | 0 | 4 | 0.80 |
| 3 | 8 | 3 | 0 | 5 | 0.625 |
| 4 | 9 | 1 | 0 | 8 | 0.89 |
| 5 | 15 | 6 | 0 | 9 | 0.60 |

## Interview transcript

<details>
<summary>Round 1 - Goal clarity - ambiguity 76.5%</summary>

Question: What should this starter fundamentally optimize for?

Answer: All four: API-backed production apps, enterprise apps, offline-first
apps, and a modular universal kit.

</details>

<details>
<summary>Round 2 - Constraint clarity - ambiguity 46%</summary>

Question: Should generated apps receive every capability, or should the
starter expose profiles and opt-in capability packs?

Answer: Every generated app should include every capability by default.

</details>

<details>
<summary>Round 3 - Success criteria - ambiguity 20.95%</summary>

Question: Which acceptance bar should define this template as complete?

Answer: Meet all three bars: end-to-end production readiness under 60 minutes,
maximum automated quality with 90% coverage, and tested/routed/localized
feature generation under 5 minutes.

</details>

<details>
<summary>Round 4 - Context clarity - ambiguity 13.45%</summary>

Question: What should the app do before auth, crash reporting, analytics,
sync, and release providers are configured?

Answer: Use vendor defaults: preselect Firebase-style services and require
credentials.

</details>

<details>
<summary>Round 5 - Publishing readiness clarification - ambiguity 9%</summary>

Question: Post-spec clarification: what publishing setup must happen before
project generation?

Answer: Collect and securely provision all App Store, Google Play, Firebase,
signing, metadata, JSON configuration, private-key, local configuration, and
GitHub secret inputs before project work starts.

</details>
