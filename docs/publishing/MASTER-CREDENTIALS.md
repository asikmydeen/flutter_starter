# Master credentials — no per-app keys

New apps do NOT generate new signing keys or service accounts. Reuse the masters.

## The model (verified 2026-08-19)
| Secret | Scope | Master lives in |
|---|---|---|
| Play service-account JSON | one Play console, all apps | vault `master/play-sa.json` (SA `quickaid-supply@quickaid-play-cicd`) — grant it per new app in Play Console → Setup → API access |
| Android upload keystore | shared across all apps (Play App Signing holds the real key) | vault `master/master-upload.jks` — register its cert when enrolling a new app |
| ASC API .p8 | per Apple Developer account | vault `horizon-tv/AuthKey_T2N9P9QG63.p8` (horizon account) / helphero key (LXKM63GT7V account) |
| iOS distribution cert + key | per Apple account | vault (horizon: 3 p12s + ios-signing.env; helphero: quickaid-distribution keypair) |

Vault = `/mnt/asik_home_8/secrets/` on the TrueNAS (see its INDEX.md). NEVER commit these.

## Per-app (cannot be shared)
- `google-services.json` / `GoogleService-Info.plist` (Firebase registration)
- applicationId / bundle id / app name
- provisioning profiles (auto-managed via ASC API)

## Wiring a new app's CI (GitHub secrets)
`KEYSTORE_BASE64`, `KEYSTORE_PASSWORD`, `KEY_ALIAS` (= master keystore), `KEY_PASSWORD`,
`PLAY_SERVICE_ACCOUNT_JSON` (= master SA) — plus per-Apple-account `APPLE_API_*` /
`APPSTORE_*` from the matching master. CI workflows in this starter consume exactly these names.
Use a protected `production` environment for release jobs; `internal` for test tracks.
