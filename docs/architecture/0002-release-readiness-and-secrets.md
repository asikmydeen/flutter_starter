# ADR 0002: Release Readiness and Secret Placement

Status: Accepted on 2026-08-17

Generated-project work is blocked until the versioned readiness inputs reach
`READY`. Initial Apple and Google app records remain human-created.

Checked-in manifests contain nonsecret identifiers and policy only. Local
`.env.release.local` contains references, never credential values. Actual
credentials use external `0700` directories, `0600` files, the OS keychain,
and protected GitHub environment secrets. Google automation defaults to OIDC
and Workload Identity Federation.

Readiness is invalidated whenever canonical inputs or credential fingerprints
change. Dry-run performs no mutation; rotation validates before switching and
requires human retirement of the prior provider credential.
