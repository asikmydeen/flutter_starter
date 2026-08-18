# Product Spec - Production Flutter Starter

> Status: APPROVED on 2026-08-17. Implementation is in progress at M0. This
> document is the source of truth for implementation.

## Purpose

Enable Flutter teams to produce secure, observable, accessible, offline-capable
iOS and Android applications quickly, while retaining the existing opinionated
Riverpod architecture and one-command verification workflow.

## Users & roles

- App developers bootstrap projects and build features.
- Platform maintainers evolve shared foundations and generators.
- QA and security engineers define and enforce release gates.
- Release engineers configure credentials, signing, and distribution.

## Pre-project release-readiness gate

Project generation is blocked until a resumable release-readiness wizard has
collected, stored, and validated all required publishing inputs. The wizard
must run before branding, dependency installation, or feature generation.

Readiness states are:

`DRAFT -> ANSWERED -> RESOURCES_VALIDATED -> GITHUB_CONFIGURED -> APPROVED -> READY`

Missing input, authentication, external resources, or unsafe secret handling
enters a typed blocked state. There is no force or skip option. The wizard
saves only redacted state and resumes from the first stale or failed check.

### Shared publishing inputs

- Legal app and publisher names, organization namespace, support contacts,
  default locale, version/build policy, monetization, target countries, and
  release strategy.
- App name, descriptions, categories, copyright, support URL, privacy-policy
  URL, account-deletion URL, marketing URL, review contacts, demo-account
  credentials, and reviewer instructions.
- Approved icons, screenshots, preview media, feature graphics, translations,
  and release-note sources.
- Data collection/sharing, consent, ads, age/target audience, content rights,
  encryption/export compliance, restricted permissions, and account-deletion
  declarations. The wizard records answers but never invents legal facts.
- Public store contacts may be nonsecret manifest values. Legal identities,
  private review contacts, tester lists, and other nonpublic personal data are
  confidential and never stored in source control or `.env*`.

### Apple inputs

- Apple Developer membership/account type and status, Team ID, App Store
  Connect roles, agreement status, bundle ID, SKU, App Store Connect app record ID, primary
  language, categories, pricing, availability, TestFlight groups, release mode,
  DSA trader status, age rating, content rights, and App Privacy responses.
- App Store Connect API private `.p8`, key ID, issuer ID, key type, role,
  creation date, rotation owner, and one-time-download backup confirmation.
- Signing strategy. Manual signing collects distribution `.p12`, password,
  certificate fingerprint/expiry, provisioning profile, entitlements, and
  `ExportOptions.plist`; supported cloud-managed signing records its validated
  account and team configuration instead.
- APNs `.p8`, APNs key ID, Team ID, topics, and environment when push is used.
  APNs and App Store Connect keys are treated as different credentials.
- `GoogleService-Info.plist`, Firebase iOS app ID, privacy manifest,
  required-reason API declarations, export-compliance status, screenshots,
  app icon, review contact, stable review account, and support/privacy URLs.

### Google Play inputs

- Google Play developer account type/status, developer ID, verified legal/public
  contacts, agreement status, Google Play Console app record, production application ID, default
  language, app/game choice, free/paid choice, countries, tracks, tester groups,
  category/tags, managed-publishing choice, and release policy.
- Play App Signing status and public fingerprints, upload `.jks`/`.keystore`,
  alias, store password, key password, certificate fingerprint/expiry, backup
  owner, and upload-key reset status when applicable.
- Google Cloud project, Play Developer API status, least-privilege publishing
  identity, and Workload Identity Federation configuration. A service-account
  JSON key is accepted only as a legacy fallback and is treated as a private
  credential file.
- `google-services.json`, Firebase Android app ID, Firebase project mapping,
  App Check status, and Play app-signing fingerprints registered with Firebase.
- Data Safety, account deletion, ads, target audience/Families, content rating,
  app access, financial/health/news/government declarations, sensitive
  permission declarations, store listing text, icon, feature graphic,
  screenshots, preview video, support contacts, and privacy URLs.

### Secret placement

- `.env.release.local` is gitignored and contains nonsecret values plus
  `file://` or `keychain://` references only. It never contains private-key
  bodies, passwords, tokens, Base64 credentials, or service-account JSON.
- Private local files live under a user-owned directory outside the repository,
  with directory mode `0700` and file mode `0600`. Passwords use the operating
  system keychain or an approved password manager.
- Checked-in `config/release_readiness.json` contains nonsecret identifiers,
  expected GitHub secret names, fingerprints, and policy decisions only.
- GitHub uses protected `release-internal` and `release-production`
  environments. Private keys, signing files, and passwords are encrypted
  environment secrets; IDs, package names, tracks, and project names are
  environment variables or checked-in nonsecret configuration.
- Google publishing uses GitHub OIDC and Workload Identity Federation by
  default. Provider trust is restricted to the expected organization and
  repository IDs, protected environment, ref/tag, workflow identity, subject,
  and audience.
- Service-account JSON requires an approved exception with owner, rationale,
  expiry of at most 90 days, and rotation plan. It remains a restricted local
  file and protected GitHub environment secret, never an `.env` value.
- The wizard verifies `gh` authentication, repository ownership, environment
  protection, reviewers, protected refs, least-privilege workflow permissions,
  and full-SHA action pinning before writing GitHub configuration.
- Remote secret writes are shown as a redacted plan and require one explicit
  confirmation. Values are streamed over standard input and never appear in
  process arguments, logs, state files, or reports.

### Automation boundary

The wizard may generate Android upload keys and derived store assets when the
publisher authorizes it, securely place imported credentials, provision GitHub
environments/variables/secrets, and retrieve provider configuration through
official APIs. Apple, Google Play, and Firebase operations otherwise remain
read-only validation and configuration retrieval.

The wizard and release automation never create the initial App Store Connect
or Google Play Console app record, even with elevated permissions or explicit
confirmation. They also never create or accept legal developer accounts,
agreements, tax/banking records, identity verification, or recover one-time
Apple private keys. For those prerequisites the wizard provides exact actions,
enters `BLOCKED_EXTERNAL_RESOURCE`, and resumes only after validating the
human-supplied resource.

## Core flows (priority order)

| # | Flow | Feature folder | Foundations | Status |
|---|---|---|---|---|
| 1 | Complete publishing, signing, Firebase, secret, and GitHub readiness | none | `tool/release_readiness.dart`, `config/release_readiness.json`, protected environments | not started |
| 2 | Configure and brand a fresh project | none | `tool/`, `lib/core/config/`, iOS, Android | not started |
| 3 | Authenticate and call the authoritative API securely | `lib/features/auth/` | `lib/core/auth/`, `lib/core/network/`, secure storage | not started |
| 4 | Read and mutate Todos offline, then synchronize safely | `lib/features/todos/` | `lib/core/database/`, `lib/core/sync/`, connectivity | not started |
| 5 | Generate a routed, localized, tested feature | generated `lib/features/<name>/` | `tool/new_feature.dart`, router, localization, test templates | partial |
| 6 | Observe, diagnose, and control a running release | `lib/features/diagnostics/` | `lib/core/observability/`, messaging, Remote Config | not started |
| 7 | Verify accessibility, security, performance, licenses, and correctness | none | `tool/verify.sh`, tests, CI | partial |
| 8 | Build and distribute signed internal releases | none | release workflows, signing, platform projects | not started |

## First demo (walking skeleton)

After M1 reaches `READY` and before broad foundation work, M2 demonstrates one
thin path on iOS and Android: load `dev` configuration, authenticate with email
and password, fetch a Todo through the reference API, persist and render it,
edit it offline, survive process restart, synchronize after reconnection, and
emit one correlated diagnostic event. Firebase emulators and the reference API
are allowed; an in-memory-only fake is not. The demo must pass before secondary
capabilities or another feature are implemented.

## Out of scope (v1)

- Replacing Riverpod, go_router, Dio, Freezed, json_serializable, or the
  feature-first architecture.
- Supporting arbitrary choices of state manager, router, HTTP client,
  database, or cloud vendor.
- Using Firestore as a second authoritative domain store. The custom API is
  authoritative; Firebase provides platform services.
- Generating business rules from an entity name or schema.
- Solving every domain-specific merge conflict automatically.
- Creating initial App Store Connect or Google Play Console app records. A
  human publisher creates each record; tooling validates supplied identifiers.
- Creating or accepting legal developer accounts, agreements, tax/banking
  records, or identity verification.
- Including app-store review time in the 60-minute benchmark.
- Claiming regulatory certification such as PCI, HIPAA, or SOC 2.
- Adding web or desktop targets in this scope. The starter remains focused on
  iOS and Android, including phone, tablet, portrait, and landscape layouts.

## Backend & data

- **Domain API**: A user-supplied HTTPS API is authoritative. `starter.yaml`
  requires separate `dev`, `staging`, and `prod` base URLs, exposed only through
  `AppConfig`. No environment inherits or falls back to another. Placeholder,
  malformed, or non-HTTPS staging/production URLs fail startup and release
  preflight.
- **Reference contract**: The versioned OpenAPI contract lives at
  `docs/openapi/reference_api.yaml` and is the sole wire-format authority for
  contract tests and generated adapters.
- **Firebase**: Firebase Auth by default, with Identity Platform-compatible
  enterprise adapters, plus App Check, Crashlytics, Analytics, Performance
  Monitoring, Messaging, and Remote Config.
- **Auth methods**: Login is required by the reference app. It supports Firebase
  email/password, Google Sign-In on iOS and Android, and Sign in with Apple on
  iOS. Phone, anonymous, SAML, and OIDC remain extension points.
- **Token refresh**: Requests attach a Firebase ID token. The Firebase SDK owns
  refresh-token persistence. After one `401`, Dio forces one ID-token refresh
  and retries once. A second `401` signs out, clears auth-scoped local data, and
  restores the intended route after reauthentication. Non-idempotent requests
  retry only with an idempotency key.
- **Sensitive storage**: Application code never copies ID or refresh tokens to
  shared preferences, SQLite, logs, analytics, or generated assets. Managed
  secrets use Keychain or Android Keystore-backed storage. Logout and account
  deletion erase auth-scoped secrets and sensitive cached data.
- **Reference roles**: Claims use `role=user|admin` and `tenant_id`. A `user`
  manages their own Todos. An `admin` may also inspect tenant diagnostics and
  resolve tenant sync conflicts. The API enforces permissions; UI checks only
  control presentation.
- **Required configuration**: Runtime startup fails with an actionable,
  localized configuration error when mandatory vendor configuration is
  absent. Tests and PR CI use fakes or Firebase emulators, never production
  credentials.
- **Local source of truth**: Drift/SQLite stores domain data, sync metadata,
  durable mutations, tombstones, and unresolved conflicts.
- **Sync**: Mutations are committed locally with an outbox entry. Delivery is
  at least once, protected by API idempotency keys and entity versions.
- **Conflicts**: Disjoint field changes may merge automatically. Overlapping
  changes persist the base, local, and remote values for domain or user
  resolution.
- **Pagination**: Cursor-based reference contract.
- **Realtime**: Push or a replaceable invalidation hook triggers synchronization;
  realtime domain transport is not a second source of truth.

Reference Todo response payload:

```json
{
  "id": "todo-01JABCDEF0123456789",
  "title": "Buy milk",
  "completed": false,
  "version": 7,
  "createdAt": "2026-08-17T00:00:00Z",
  "updatedAt": "2026-08-17T00:05:00Z",
  "deletedAt": null
}
```

Reference Todo mutation payload:

```json
{
  "idempotencyKey": "<generated-uuid>",
  "baseVersion": 7,
  "operation": "update",
  "todo": {
    "title": "Buy oat milk",
    "completed": true
  }
}
```

## Default capabilities

Every generated app includes and wires these capabilities. Internal interfaces
keep them testable and replaceable, but they are not optional starter packs.

- Validated project manifest, environment flavors, branding, icons, splash,
  bundle identifiers, Firebase project mapping, and credential preflight.
- Mandatory pre-project Apple/Google publishing intake, secure local secret
  import, GitHub environment provisioning, live provider validation, dry-run,
  resumability, and credential-rotation workflows.
- Firebase authentication, App Check, secure storage, route guards, tenant and
  role context, session expiry, and logout data cleanup.
- Hardened Dio client with token injection, correlation IDs, redaction,
  cancellation, bounded idempotent retries, pagination, and typed failures.
- Drift database, migrations, local-first repositories, durable outbox,
  synchronization diagnostics, tombstones, and conflict storage.
- Crashlytics, Analytics, Performance Monitoring, Remote Config, structured
  logging, release metadata, and consent-controlled data collection.
- Push notifications, deep links, authenticated redirect restoration,
  background synchronization, and foreground-resume fallback.
- Material 3 design tokens, adaptive navigation, responsive layouts,
  light/dark/high-contrast themes, RTL readiness, and text scaling.
- Localized errors and UI strings with pseudo-long and RTL test coverage.
- Privacy controls, analytics consent, local-data erase, diagnostics export,
  environment display, and account deletion hooks.
- Complete feature scaffolding, deterministic fixtures, migration helpers,
  architecture checks, and benchmark tooling.
- Unit, widget, contract, integration, golden, accessibility, security,
  performance, migration, and release verification.

## Design

- **Source**: Tokenized Material 3 reference system; generated apps replace
  manifest values with product-specific brand assets.
- **Tone**: Calm, trustworthy, and utilitarian. Authentication and CRUD screens
  are spacious; readiness and diagnostics screens are information-dense.
  Decorative gradients, glass effects, novelty motion, and ambiguous icon-only
  actions are prohibited.
- **Brand**: Seed color, logo, icons, splash, and optional font family come
  from the project manifest.
- **Themes**: Light, dark, high contrast, and system-following modes.
- **Navigation**: Adaptive stack or destination navigation selected from the
  number of top-level flows; named routes only.
- **Must-match screens**: No external screenshots exist. Sign in, Todo list,
  Todo editor, sync conflict, diagnostics, and privacy/settings become the
  starter's canonical golden references during M2-M4.
- **Responsive bar**: No overflow or inaccessible primary action at supported
  phone/tablet widths, landscape, RTL, or 200% text scale.

## Platform

- Targets: iOS 13.0 or later and Android API 24 or later. Android release
  builds target API 36.
- Form factors: phone and tablet, portrait and landscape.
- Offline: local-first reads and queued writes for reference CRUD flows.
- Push: Firebase Messaging.
- Deep links: iOS universal links and Android app links.
- Background work: platform-supported scheduling plus foreground-resume sync.

## Non-functional

- Languages: English reference strings, with full localization infrastructure,
  pseudo-long tests, and RTL tests.
- Accessibility: WCAG 2.2 AA target, semantic labels, contrast, keyboard/focus
  order where applicable, touch targets, and 200% text-scale support.
- Coverage: at least 90% of handwritten lines globally and 95% for critical
  auth, configuration, storage, and sync modules.
- Security: blocking secret and vulnerability scans, time-bounded waivers only
  for approved dependency findings, log-redaction tests, forbidden-material
  scans, least-privilege CI, protected release environments, and no embedded or
  plaintext secrets. Secret leaks, unredacted logs, debug release signing, and
  generated-code drift are never waivable.
- Performance: cold start at most 3 seconds on the pinned reference device,
  less than 1% janky frames in reference flows, and no unexplained artifact
  size or benchmark regression above 10%.
- Scaffold benchmark: 20 consecutive warm-cache generations use unique feature
  names and clean output directories. p95 must be at most 5 minutes, and every
  run must produce complete, valid, immediately verifiable output.
- Dependency licenses: denied or unknown licenses block readiness and CI unless
  an identified owner records a rationale and expiry for the waiver.
- Offline: queued writes survive process death and converge within 30 seconds
  after connectivity returns under the reference API.
- Store release: signed internal distribution is in scope. Public store review
  and production promotion require explicit human approval.

## Acceptance criteria

| ID | Criterion |
|---|---|
| AC-1 | Three independent clean trials, each from a fresh clone with no local wizard state or GitHub release environments, produce a branded, observable, offline-capable signed internal release in at most 60 minutes. Human-created store records and required credentials exist before each clock starts. |
| AC-2 | Across 20 consecutive warm-cache feature-generation runs, p95 duration is at most 5 minutes. Every run creates all layers, remote/local data, routing, localization, fixtures, and data/application/presentation/sync tests with no TODO markers. |
| AC-3 | CI reports at least 90% handwritten line coverage globally and 95% for auth, configuration, storage, and sync; omitted handwritten files count as uncovered. |
| AC-4 | Reference offline Todo CRUD survives process death, duplicate delivery is idempotent, and queued mutations converge within 30 seconds after connectivity returns. |
| AC-5 | Every reference screen passes automated semantics, contrast, touch-target, text-scale, focus, and responsive checks. |
| AC-6 | High/critical vulnerabilities and denied/unknown licenses block CI unless an owned, expiring waiver applies. Leaked secrets, unredacted sensitive logs, debug release signing, and generated-code drift are never waivable. |
| AC-7 | M6 owns release-gate policy and results. M7 consumes only M1-provisioned environments, produces installable Android/iOS internal artifacts, and uploads and retains dSYM, ProGuard/R8 mapping, and native symbols before distribution. |
| AC-8 | Performance benchmarks pass the fixed-device budgets and reject regressions above 10%. |
| AC-9 | Local and PR test workflows require no production Firebase credentials and cannot select a production Firebase project. |
| AC-10 | `./tool/verify.sh` remains the deterministic local definition of done and passes after every milestone. |
| AC-11 | Project generation exits nonzero unless `config/release_readiness.json` is approved and `READY` for the current `config/release_readiness.json` digest. |
| AC-12 | The wizard securely collects every applicable Apple, Google Play, Firebase, signing, metadata, privacy, review, and CI input before generation and records explicit not-applicable decisions. |
| AC-13 | No private key, service-account JSON, signing asset, password, or token appears in `.env*`, source control, wizard state, process arguments, logs, reports, or generated client assets. |
| AC-14 | Interrupted intake resumes atomically; missing external resources block with exact remediation and do not create project files. |
| AC-15 | A redacted dry-run performs no filesystem, keychain, configuration, GitHub, provider, build, upload, or store mutation. |
| AC-16 | Live validation proves Apple, Google Play, Firebase, signing, and GitHub resources/API access exist, map to expected identifiers, are unexpired, and have least privilege. GitHub validation covers authentication, repository ownership, named environments, reviewers, protected refs, workflow permissions, full-SHA action pins, and OIDC trust restrictions for organization/repository IDs, environment, ref/tag, workflow, subject, and audience. |
| AC-17 | M1 provisions and validates `release-internal` and `release-production`. M7 cannot create or weaken them. Credentials remain inaccessible to pull requests, forks, Dependabot, and untrusted triggers. |
| AC-18 | Rotation validates the replacement before switching GitHub; failed validation leaves the active credential unchanged. Tooling never revokes the old provider credential automatically, but records a mandatory human revocation action due within 24 hours and verifies completion. |
| AC-19 | Dependency-license reports contain no denied or unknown license without an owned, expiring waiver. |
| AC-20 | The wizard and release automation never create an initial App Store Connect or Google Play Console app record; they block with exact instructions and resume after validating human-supplied IDs. |
| AC-21 | Nonpublic legal identities, review contacts, tester lists, and personal data are absent from source and `.env*`; they use an external `0600` private metadata file and, only when CI needs them, a protected environment secret. |

## Milestones

| ID | Milestone | Contains | Exit status |
|---|---|---|---|
| M0 | Contracts and baseline | ADRs, manifest/OpenAPI schemas, benchmarks, license policy, current bug fixes | complete - verified 2026-08-17 |
| M1 | Publishing readiness | Wizard, secure storage, protected environment provisioning, provider validation | blocked - publisher inputs required |
| M2 | Walking skeleton | Minimal auth, API, Todo persistence/offline sync, diagnostics, first-demo approval | in progress - host sync/restart/UI integration verified |
| M3 | Production/offline foundations | Hardened auth/network/observability, Drift, migrations, outbox, conflicts | in progress - Drift/outbox/conflict foundation verified |
| M4 | Reference slice completion | Complete offline Todos, roles, deep links, push, privacy, diagnostics | in progress - roles/privacy/diagnostics/push seams verified |
| M5 | Generators | Readiness assertion, project bootstrap, doctor, atomic feature scaffolder | in progress - atomic files/routes/l10n/tests verified |
| M6 | Quality and release gates | Coverage, accessibility, security, licenses, performance, integration, release policy | in progress - coverage/a11y/responsive/security gates verified |
| M7 | Release automation | Consume M1 environments; signed builds, symbols, internal distribution, provenance, rollback | in progress - [Android/iOS release compilation verified](https://github.com/asikmydeen/flutter_starter/actions/runs/32101885889); signed distribution blocked on M1 |
| M8 | Qualification | Three clean readiness/bootstrap trials and 20-run scaffold p95 benchmark | in progress - [20-run scaffold p95 verified at 840 ms](https://github.com/asikmydeen/flutter_starter/actions/runs/32101885122); three readiness-to-release trials blocked on M1 |

Each milestone is implemented and verified separately. Later milestones do not
start until their dependency contracts and tests pass.

Template implementation may use deterministic fakes and emulators before a
specific generated app has live publisher credentials. This does not permit
project generation or release; those remain blocked until that app's readiness
digest is `READY`.

## Assumptions log

- The starter targets iOS and Android only; web and desktop are excluded from
  this scope. Default applied on 2026-08-17.
- The custom API is authoritative; Firebase is the default platform-services
  vendor. Default applied on 2026-08-17.
- Firebase data collection is included but remains disabled until the app's
  consent policy permits it. Default applied on 2026-08-17.
- The 60-minute clock starts on a supported, pre-provisioned machine after
  required credentials and signing assets are available. Default applied on
  2026-08-17.
- The 5-minute feature clock uses warm dependencies in an already bootstrapped
  project. Default applied on 2026-08-17.
- Public store submission and review are excluded from automated release time.
  Default applied on 2026-08-17.
- External account enrollment, legal review, D-U-N-S provisioning, store-record
  creation, and agreement approval complete before the 60-minute technical
  benchmark begins. Default applied on 2026-08-17.
- Local `.env` files may hold references and nonsecret configuration only;
  actual credentials use restricted files or the OS keychain. Security override
  applied on 2026-08-17.
- API URLs are supplied separately in `starter.yaml` for `dev`, `staging`, and `prod`; the local
  reference contract path is `docs/openapi/reference_api.yaml`. Default applied
  on 2026-08-17.
- Reference authentication uses email/password, Google, and Apple with
  `user`/`admin` claims. Default applied on 2026-08-17.
- Minimum platforms are iOS 13.0 and Android API 24. Approved on 2026-08-17 to
  match the pinned Flutter 3.44.8 SDK default.
- Local iOS compilation is deferred on the current machine because full Xcode
  is absent. iOS source/configuration and the macOS CI compile gate remain in
  scope. User override recorded on 2026-08-17.
- Design defaults to calm, trustworthy Material 3 with no external must-match
  screenshots. Default applied on 2026-08-17.

## Decision log

- 2026-08-17: Optimize for API-backed, enterprise, offline-first, broadly
  reusable apps. Rationale: solve cross-cutting production requirements once
  instead of retrofitting every generated app.
- 2026-08-17: Include all capabilities by default. Rationale: profiles make
  projects inconsistent and can omit security, observability, or offline needs.
- 2026-08-17: Use Firebase for platform services while the custom API remains
  authoritative. Rationale: avoid a dual-write domain architecture.
- 2026-08-17: Enforce readiness, quality, and speed bars together. Rationale:
  fast but incomplete or unsafe generated output is not successful.
- 2026-08-17: Require publishing, signing, Firebase, and CI readiness before
  generation. Rationale: external account and signing blockers have long lead
  times and must be exposed before feature work.
- 2026-08-17: M1 provisions protected GitHub environments and M7 only consumes
  them. Rationale: a release workflow must not weaken its own controls.
- 2026-08-17: M6 owns release-gate policy; M7 owns release symbols and artifacts.
  Rationale: gate policy remains independent while symbols stay tied to builds.
- 2026-08-17: Never automate initial store-record creation. Rationale: initial
  records contain legal, commercial, and immutable identifier decisions owned
  by an accountable human publisher.
- 2026-08-17: Continue template implementation with fakes/emulators while live
  publisher readiness remains incomplete. Rationale: the gate applies to
  generated projects and releases, while reusable template code can be built
  and tested without production credentials. Local iOS compilation is deferred,
  not removed from CI or product scope.
