#!/usr/bin/env bash
# The single verification command. Run this before declaring any task done.
#
#   ./tool/verify.sh          # local: regenerates code, formats in place
#   ./tool/verify.sh --ci     # CI: fails on format/codegen drift instead
#
# Steps: deps -> l10n -> codegen -> format -> analyze -> tests -> coverage.
# Exits non-zero on the first failure.
set -euo pipefail
cd "$(dirname "$0")/.."

CI_MODE=false
[[ "${1:-}" == "--ci" ]] && CI_MODE=true

MIN_COVERAGE="${MIN_COVERAGE:-70}"

# Prefer FVM's pinned SDK when available.
if command -v fvm >/dev/null 2>&1 && [[ -f .fvmrc ]]; then
  FLUTTER="fvm flutter"
  DART="fvm dart"
else
  FLUTTER="flutter"
  DART="dart"
fi

step() { printf '\n\033[1m== %s ==\033[0m\n' "$1"; }

step "Dependencies"
$FLUTTER pub get

step "Localization codegen"
$FLUTTER gen-l10n

step "Codegen (freezed / riverpod / json)"
$DART run build_runner build --delete-conflicting-outputs

if $CI_MODE; then
  step "Codegen drift check"
  if ! git diff --exit-code -- '*.g.dart' '*.freezed.dart' lib/l10n/gen; then
    echo "ERROR: generated files are stale. Run ./tool/verify.sh locally and commit the results." >&2
    exit 1
  fi
fi

step "Format"
if $CI_MODE; then
  $DART format --set-exit-if-changed .
else
  $DART format .
fi

step "Analyze"
$FLUTTER analyze

step "Tests (excluding goldens) + coverage"
$FLUTTER test --exclude-tags golden --coverage

step "Coverage floor (min ${MIN_COVERAGE}%)"
# Compute line coverage from lcov.info, excluding generated files
# (*.g.dart, *.freezed.dart, lib/l10n/gen) so the floor reflects
# hand-written code only. LF = lines found, LH = lines hit.
awk -v min="$MIN_COVERAGE" '
  /^SF:/ { skip = ($0 ~ /\.g\.dart$|\.freezed\.dart$|lib\/l10n\/gen\//) }
  /^LF:/ { if (!skip) total += substr($0, 4) }
  /^LH:/ { if (!skip) hit   += substr($0, 4) }
  END {
    if (total == 0) { print "ERROR: no coverage data produced." > "/dev/stderr"; exit 1 }
    pct = hit * 100 / total
    printf "Line coverage: %.1f%% (%d/%d, generated files excluded)\n", pct, hit, total
    if (pct < min) {
      printf "ERROR: coverage %.1f%% is below the %d%% floor.\n", pct, min > "/dev/stderr"
      exit 1
    }
  }
' coverage/lcov.info

printf '\n\033[1;32mVERIFY PASSED\033[0m\n'
