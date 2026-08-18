# Product Spec — <app name>

> Filled in by the intake protocol (`docs/INTAKE.md`). Single source of
> truth for the build. If code and spec disagree, STOP and reconcile.
> Copy this file to `docs/PRODUCT_SPEC.md` and delete the placeholders.

- **Status**: DRAFT / APPROVED
- **Approval date**: <required>
- **Current milestone**: M0
- **Readiness stage**: DRAFT
- **Readiness evidence**: `config/release_readiness.json`

## Purpose

<One sentence. Who it's for and what it does.>

## Users & roles

<Roles and what each can do. "Single role" is fine.>

## Core flows (priority order)

| # | Flow | Feature folder | Foundations | Status |
|---|---|---|---|---|
| 1 | <flow> | `features/<name>` | <core/tool/platform dependencies> | not started |

## First demo (walking skeleton)

<Exact iOS/Android path, auth method, API operation, persisted offline action,
restart/reconnect behavior, diagnostic event, and approval evidence.>

## Publishing readiness

- Initial App Store Connect and Google Play Console records: human-created.
- `release-internal` and `release-production`: provisioned and validated by M1.
- Secret values: external files/keychain/protected environments only.
- Current readiness digest and blocked reason: <required>.

## Out of scope (v1)

- <explicitly cut items — protects against scope creep>

## Backend & data

- **API**: independent dev/staging/prod URLs and OpenAPI path; custom API is authoritative.
- **Auth**: Firebase methods, ID-token refresh, erase lifecycle, roles/claims.
- **Offline**: Drift local source, outbox, idempotency, versions, tombstones, conflicts.
- **Entities** (sample payloads or field lists):

```json
{ "example_entity": { "id": 1 } }
```

- **Pagination**: <style or "none">  ·  **Realtime**: <or "none">

## Design

- **Source**: <Figma link / screenshots location / reference app / "generic Material 3">
- **Brand**: seed color `<hex>`, fonts <or system>, dark mode <yes/no>
- **Navigation**: <bottom tabs / stack / drawer, with the tab list>
- **Must-match screens**: <screenshots + which parts must match>

## Platform

- Targets: iOS 13+ and Android API 24+ / target 36. Tablet and landscape included.
- Push: <y/n> · Deep links: <y/n>

## Non-functional

- Languages: <list>; Firebase analytics/crash/performance with consent.
- Coverage: 90% global, 95% auth/config/storage/sync.
- Accessibility: WCAG 2.2 AA, 200% text, semantics, contrast, focus.
- Performance budgets: <reference devices and thresholds>.

## Milestones

| ID | Milestone | Status | Evidence |
|---|---|---|---|
| M0 | Contracts and baseline | not started | <link/report> |
| M1 | Publishing readiness | not started | <link/report> |
| M2 | Walking skeleton | not started | <link/report> |
| M3 | Production/offline foundations | not started | <link/report> |
| M4 | Reference slice completion | not started | <link/report> |
| M5 | Generators | not started | <link/report> |
| M6 | Quality and release gates | not started | <link/report> |
| M7 | Release automation | not started | <link/report> |
| M8 | Qualification | not started | <link/report> |

## Acceptance criteria

| ID | Criterion | Evidence | Status |
|---|---|---|---|
| AC-1 | <measurable result> | <test/report> | not started |

## Assumptions log

> Every intake default the user did not explicitly confirm. Revisit before ship.

- <assumption> (default applied on <date>)

## Decision log

> Material decisions made during the build, with why.

- <date>: <decision — rationale>
