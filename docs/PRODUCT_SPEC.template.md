# Product Spec — <app name>

> Filled in by the intake protocol (`docs/INTAKE.md`). Single source of
> truth for the build. If code and spec disagree, STOP and reconcile.
> Copy this file to `docs/PRODUCT_SPEC.md` and delete the placeholders.

## Purpose

<One sentence. Who it's for and what it does.>

## Users & roles

<Roles and what each can do. "Single role" is fine.>

## Core flows (priority order)

| # | Flow | Feature folder | Status |
|---|------|----------------|--------|
| 1 | <flow> | `features/<name>` | not started |

## Out of scope (v1)

- <explicitly cut items — protects against scope creep>

## Backend & data

- **API**: <base URLs per env, docs link — or "local-only" / BaaS choice>
- **Auth**: <method, token type, refresh flow — or "none">
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

- Targets: <iOS/Android, min versions> · Tablet: <y/n> · Offline: <mode>
- Push: <y/n> · Deep links: <y/n>

## Non-functional

- Languages: <list> · Analytics/crash: <choice> · Store release in v1: <y/n>

## Milestones

| # | Milestone | Contains | Verified (verify.sh) | Demoed |
|---|-----------|----------|----------------------|--------|
| 0 | Walking skeleton | nav shell, theme, flow #1 | ☐ | ☐ |

## Assumptions log

> Every intake default the user did not explicitly confirm. Revisit before ship.

- <assumption> (default applied on <date>)

## Decision log

> Material decisions made during the build, with why.

- <date>: <decision — rationale>
