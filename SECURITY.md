# Security Policy

Report vulnerabilities through GitHub private security advisories. Do not open
public issues containing exploit details, credentials, tokens, PII, private
store metadata, signing fingerprints tied to private material, or raw provider
output.

Include the affected commit, impact, minimal reproduction, and a redacted log.
Never attach `.p8`, `.p12`, `.jks`, `.mobileprovision`, service-account JSON,
Firebase environment files, or `.env.release.local`.

High/critical dependency findings may use an owned, expiring waiver. Secret
leaks, unredacted sensitive logs, debug release signing, and generated-code
drift are not waivable.
