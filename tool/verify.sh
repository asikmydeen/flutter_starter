#!/usr/bin/env bash
# The single deterministic verification command.
set -euo pipefail
cd "$(dirname "$0")/.."

case "${1:-}" in
  "") CI_MODE=false ;;
  --ci) CI_MODE=true ;;
  *) printf 'Usage: %s [--ci]\n' "$0" >&2; exit 64 ;;
esac

PINNED_FLUTTER="$(jq -r .flutter .fvmrc)"
if command -v fvm >/dev/null 2>&1; then
  FLUTTER=(fvm flutter)
  DART=(fvm dart)
elif command -v flutter >/dev/null 2>&1 && command -v dart >/dev/null 2>&1; then
  ACTUAL_FLUTTER="$(flutter --version --machine | jq -r .frameworkVersion)"
  if [[ "$ACTUAL_FLUTTER" != "$PINNED_FLUTTER" ]]; then
    printf 'ERROR: Flutter %s required; found %s. Install FVM.\n' "$PINNED_FLUTTER" "$ACTUAL_FLUTTER" >&2
    exit 1
  fi
  FLUTTER=(flutter)
  DART=(dart)
else
  printf 'ERROR: FVM/Flutter is missing. Run: brew install fvm && fvm install\n' >&2
  exit 1
fi

step() { printf '\n\033[1m== %s ==\033[0m\n' "$1"; }

step "Static manifests"
jq empty config/schemas/*.json config/*.json config/security/*.json metadata/store/*.json metadata/store/assets/*.json tool/benchmarks/*.json opencode.json skills-lock.json .skills.json
"${DART[@]}" run tool/validate_manifests.dart

step "Agent skill locks"
while IFS= read -r skill; do
  if [[ ! -f ".agents/skills/$skill/SKILL.md" ]]; then
    printf 'ERROR: locked agent skill is missing: %s\n' "$skill" >&2
    exit 1
  fi
done < <(jq -r '.skills | keys[]' skills-lock.json)
LOCKED_SKILL_COUNT="$(jq '.skills | length' skills-lock.json)"
INSTALLED_SKILL_COUNT=0
for skill_file in .agents/skills/*/SKILL.md; do
  [[ -f "$skill_file" ]] && INSTALLED_SKILL_COUNT=$((INSTALLED_SKILL_COUNT + 1))
done
if [[ "$LOCKED_SKILL_COUNT" -ne "$INSTALLED_SKILL_COUNT" ]]; then
  printf 'ERROR: project skill count (%s) differs from lock (%s).\n' \
    "$INSTALLED_SKILL_COUNT" "$LOCKED_SKILL_COUNT" >&2
  exit 1
fi

step "Forbidden tracked credentials"
while IFS= read -r tracked; do
  case "$tracked" in
    *.p8|*.p12|*.mobileprovision|*.jks|*.keystore|*service-account*.json|*service_account*.json|*/google-services.json|*/GoogleService-Info.plist|*private-store-metadata*.json)
      printf 'ERROR: forbidden credential material is tracked: %s\n' "$tracked" >&2
      exit 1
      ;;
  esac
done < <(git ls-files)

step "Dependencies"
"${FLUTTER[@]}" pub get

step "Localization codegen"
"${FLUTTER[@]}" gen-l10n

step "Codegen (freezed / riverpod / json)"
"${DART[@]}" run build_runner build

if $CI_MODE; then
  step "Generated-code drift"
  GENERATED_STATUS="$(git status --porcelain --untracked-files=all -- '*.g.dart' '*.freezed.dart' 'lib/l10n/gen/**')"
  if [[ -n "$GENERATED_STATUS" ]]; then
    printf 'ERROR: generated files are stale or untracked:\n%s\n' "$GENERATED_STATUS" >&2
    exit 1
  fi
fi

step "Format"
FORMAT_PATHS=(lib test tool)
if [[ -d integration_test ]]; then FORMAT_PATHS+=(integration_test); fi
if $CI_MODE; then
  "${DART[@]}" format --set-exit-if-changed "${FORMAT_PATHS[@]}"
else
  "${DART[@]}" format "${FORMAT_PATHS[@]}"
fi

step "Analyze"
"${FLUTTER[@]}" analyze

step "Tests + coverage"
"${FLUTTER[@]}" test \
  --exclude-tags 'golden || integration || slow' \
  --coverage

step "Coverage floors"
"${DART[@]}" run tool/check_coverage.dart \
  --global-min="${MIN_COVERAGE:-90}" \
  --critical-min="${CRITICAL_MIN_COVERAGE:-95}"

printf '\n\033[1;32mVERIFY PASSED\033[0m\n'
