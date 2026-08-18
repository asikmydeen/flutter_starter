# ADR 0003: Platform and Quality Baseline

Status: Accepted on 2026-08-17

The starter targets iOS 13 or newer and Android API 24 or newer, with Android
target API 36. Flutter is pinned to 3.44.8 through FVM.

The local definition of done is `./tool/verify.sh`: strict manifests, forbidden
material, dependencies, localization, code generation, format, analysis,
tests, and coverage. Handwritten global coverage is at least 90%; auth,
configuration, storage, and synchronization are at least 95%.

Goldens, device integration, vulnerability scans, and release compilation use
dedicated pinned workflows because they require platform-specific hosts or
external tools.
