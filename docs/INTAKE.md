# Intake Protocol — run BEFORE building an app

> For AI agents. When the user asks you to build an app (from written
> requirements, a reference website/app, or a rough idea), do NOT start
> writing feature code. Run this protocol first. Its output is
> `docs/PRODUCT_SPEC.md` (copy `docs/PRODUCT_SPEC.template.md`), which
> becomes the single source of truth for the build.

## Rules

1. **Ask in batches, not one-by-one.** Present each section below as a
   compact set of questions in one message. Aim for 2–3 rounds total.
2. **Every question has a default.** Offer it explicitly so the user can
   reply "defaults fine, except…". Never silently assume — every default
   the user doesn't override gets logged in the spec's Assumptions section.
3. **Blocking questions must be answered** before any feature code:
   sections 1 (scope), 2 (backend), 3 (auth), and 7 (publishing readiness).
   Everything else may fall back to recorded defaults.
4. **Reference product given?** (a website or app to base this on): first
   explore it and DRAFT answers to every section yourself, then present the
   draft for correction instead of asking open questions. Ask the user for
   screenshots of the screens that matter — never guess visual design from
   HTML alone.
5. **Requirements doc given?** Extract answers from it first; only ask
   what's missing or contradictory.
6. **Close the intake** by writing `docs/PRODUCT_SPEC.md` and getting one
   explicit approval on it. Then follow the Build Order section at the
   bottom of this file.
7. **Never create initial store records.** App Store Connect and Google Play
   Console initial app records are human-created. Tooling validates IDs only.
8. **Never collect secret values in prose.** Record `file://` or `keychain://`
   references and let the readiness wizard provision protected destinations.

---

## Section 1 — Product scope (BLOCKING)

| Question | Default if unanswered |
|---|---|
| One-sentence purpose of the app? | — (must answer) |
| Who are the users? Multiple roles (admin/user/guest)? | Single user role |
| The 3–7 core user flows, in priority order? | — (must answer) |
| What is explicitly OUT of scope for v1? | Nothing cut — agent proposes cuts if scope is large |
| Reference apps/websites for functionality? | None |
| What must the first demo (walking skeleton) show? | Core flow #1, end to end |

## Section 2 — Backend & data (BLOCKING)

| Question | Default if unanswered |
|---|---|
| Does an API already exist? Supply independent dev/staging/prod URLs and OpenAPI/Swagger. | — (must answer) |
| If no API: define the authoritative HTTPS API contract and ownership. | STOP and decide; Firebase is not the generic domain store |
| Sample JSON payloads for the main entities? | Agent drafts models, user confirms |
| Pagination style (page/cursor/none)? | None (small lists) |
| Realtime needs (websockets, live updates)? | None |

## Section 3 — Auth & security (BLOCKING)

| Question | Default if unanswered |
|---|---|
| Login required? Which methods (email, phone, Google/Apple, SSO)? | Firebase email/password + Google; Apple on iOS; SSO extension points |
| Token type & refresh flow (JWT? expiry?)? | Firebase ID token; force one refresh on 401, retry once, then sign out |
| Anything sensitive to store on device (tokens, PII)? | Firebase SDK owns tokens; app secrets use Keychain/Keystore; classified offline data uses approved storage |
| Roles/permissions in the UI? | `user` and `admin` reference claims; API enforcement remains authoritative |

## Section 4 — Design & UX

| Question | Default if unanswered |
|---|---|
| Design source: Figma, screenshots, reference app, or none? | None → clean generic Material 3 |
| Brand: primary color, logo, fonts? | Template seed color, system fonts |
| Dark mode? | Yes, follows system |
| Navigation shape: bottom tabs, drawer, single stack? | Bottom tabs if 3+ top-level flows, else stack |
| Tone: information-dense vs spacious/consumer? | Spacious |
| Must-match screens (ask for screenshots)? | None |

## Section 5 — Platform & device

| Question | Default if unanswered |
|---|---|
| iOS, Android, or both? Min OS versions? | Both: iOS 13 and Android API 24 |
| Tablet/landscape support? | Phone/tablet, portrait/landscape |
| Offline behavior: none, read cache, offline-first? | Offline-first with Drift, outbox, restart recovery, and conflicts |
| Push notifications? | Firebase Messaging |
| Deep links / share links? | iOS universal links and Android app links |

## Section 6 — Non-functional

| Question | Default if unanswered |
|---|---|
| Languages beyond English? | English only (l10n scaffold ready) |
| Analytics / crash reporting? | Consent-gated Firebase Analytics, Crashlytics, and Performance |
| Accessibility bar? | WCAG 2.2 AA, semantics, contrast, touch targets, focus, and 200% text |
| Store release in scope now? | Yes: signed internal distribution and pre-project readiness |

## Section 7 — Publishing readiness (BLOCKING)

Run `fvm dart run tool/release_readiness.dart init`. The versioned questionnaire
collects shared store metadata plus all applicable Apple, Google Play, Firebase,
signing, privacy, reviewer, asset, GitHub, and secret-reference inputs.

The wizard must reach `READY` before generated-project dependency installation,
branding, or feature implementation. Missing accounts, agreements, initial app
records, one-time key downloads, or permissions produce a resumable blocked
state with exact remediation. There is no skip or force path.

---

## Build order (after spec approval)

1. **Establish readiness**: complete M0 contracts and M1 publishing readiness.
   Do not generate the project until the current manifest digest is `READY`.
2. **Decompose** the spec into features (`features/<name>/`), each mapped
   to a core flow. Order by dependency: auth → data foundations → flows in
   priority order. List this plan in the spec's Milestones section.
3. **Walking skeleton first**: navigation shell + theme + core flow #1
   wired to real (or clearly-faked) data. Demo it before going wide.
4. **One feature per cycle**: `make feature NAME=x` → implement mirroring
   `features/todos/` → `./tool/verify.sh` → commit. Never batch multiple
   unverified features.
5. **Surface spec conflicts immediately.** If implementation reveals a
   contradiction or gap in the spec, stop, ask, and update the spec — the
   spec and the code must never disagree.
6. **Update the spec's status column** as milestones complete, so any agent
   (or a fresh session) can resume from the spec alone.
