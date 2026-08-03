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
   sections 1 (scope), 2 (backend), and 3 (auth). Everything else may fall
   back to defaults.
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
| Does an API already exist? URL + docs (OpenAPI/Swagger)? | — (must answer) |
| If no API: build one, use a BaaS (Firebase/Supabase), or local-only app? | Local-only if data is personal; otherwise STOP and decide together |
| Sample JSON payloads for the main entities? | Agent drafts models, user confirms |
| Pagination style (page/cursor/none)? | None (small lists) |
| Realtime needs (websockets, live updates)? | None |

## Section 3 — Auth & security (BLOCKING)

| Question | Default if unanswered |
|---|---|
| Login required? Which methods (email, phone, Google/Apple, SSO)? | No auth |
| Token type & refresh flow (JWT? expiry?)? | Bearer token, refresh on 401 |
| Anything sensitive to store on device (tokens, PII)? | Tokens in secure storage; no PII on device |
| Roles/permissions in the UI? | None |

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
| iOS, Android, or both? Min OS versions? | Both, Flutter defaults |
| Tablet/landscape support? | Phone portrait only |
| Offline behavior: none, read cache, offline-first? | None (online required) |
| Push notifications? | No |
| Deep links / share links? | No |

## Section 6 — Non-functional

| Question | Default if unanswered |
|---|---|
| Languages beyond English? | English only (l10n scaffold ready) |
| Analytics / crash reporting? | Crash-only, provider TBD at ship time |
| Accessibility bar? | Standard: semantics labels, contrast, touch targets |
| Store release in scope now? | No — defer signing/store setup |

---

## Build order (after spec approval)

1. **Decompose** the spec into features (`features/<name>/`), each mapped
   to a core flow. Order by dependency: auth → data foundations → flows in
   priority order. List this plan in the spec's Milestones section.
2. **Walking skeleton first**: navigation shell + theme + core flow #1
   wired to real (or clearly-faked) data. Demo it before going wide.
3. **One feature per cycle**: `make feature NAME=x` → implement mirroring
   `features/todos/` → `./tool/verify.sh` → commit. Never batch multiple
   unverified features.
4. **Surface spec conflicts immediately.** If implementation reveals a
   contradiction or gap in the spec, stop, ask, and update the spec — the
   spec and the code must never disagree.
5. **Update the spec's status column** as milestones complete, so any agent
   (or a fresh session) can resume from the spec alone.
