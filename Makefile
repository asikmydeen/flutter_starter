# Convenience targets. `make verify` is the definition of done.
# Uses the exact SDK pinned in .fvmrc.

FLUTTER := fvm flutter
DART    := fvm dart
API_BASE_URL ?= http://localhost:8080

.PHONY: doctor readiness readiness-plan setup gen l10n format analyze test goldens-check goldens-update verify feature benchmark-feature run

doctor:
	$(FLUTTER) doctor -v
	$(DART) run tool/validate_manifests.dart

readiness:
	$(DART) run tool/release_readiness.dart status

readiness-plan:
	$(DART) run tool/release_readiness.dart plan

## One-time setup after clone
setup:
	$(FLUTTER) pub get
	$(FLUTTER) gen-l10n
	$(DART) run build_runner build

## Regenerate freezed/riverpod/json code
gen:
	$(DART) run build_runner build

## Regenerate localizations from ARB files
l10n:
	$(FLUTTER) gen-l10n

format:
	$(DART) format lib test tool

analyze:
	$(FLUTTER) analyze

## Fast test run (excludes goldens)
test:
	$(FLUTTER) test --exclude-tags golden

goldens-check:
	$(FLUTTER) test --tags golden

## Regenerate golden screenshots after intentional UI changes
goldens-update:
	$(FLUTTER) test --update-goldens --tags golden

## Full verification — run before declaring any task done
verify:
	./tool/verify.sh

## Scaffold a new feature: make feature NAME=my_feature
feature:
	$(DART) run tool/new_feature.dart $(NAME)

benchmark-feature:
	@test -n "$(BENCHMARK_ROOT)" || (echo "BENCHMARK_ROOT is required" && exit 64)
	$(DART) run tool/benchmark.dart --name=feature-scaffold --runs=20 --threshold-seconds=300 --working-directory=$(CURDIR) --output=build/benchmarks/feature.json -- env FEATURE_GENERATOR_ROOT=$(BENCHMARK_ROOT) $(DART) run $(CURDIR)/tool/new_feature.dart benchmark_{run}

## Run the app (dev flavor)
run:
	$(FLUTTER) run --dart-define=ENV=dev --dart-define=API_BASE_URL=$(API_BASE_URL)
