# Convenience targets. `make verify` is the definition of done.
# Uses FVM's pinned SDK when available (tool/verify.sh handles fallback).

FLUTTER := $(shell command -v fvm >/dev/null 2>&1 && echo "fvm flutter" || echo "flutter")
DART    := $(shell command -v fvm >/dev/null 2>&1 && echo "fvm dart" || echo "dart")

.PHONY: setup gen l10n format analyze test goldens verify feature run

## One-time setup after clone
setup:
	$(FLUTTER) pub get
	$(FLUTTER) gen-l10n
	$(DART) run build_runner build --delete-conflicting-outputs

## Regenerate freezed/riverpod/json code
gen:
	$(DART) run build_runner build --delete-conflicting-outputs

## Regenerate localizations from ARB files
l10n:
	$(FLUTTER) gen-l10n

format:
	$(DART) format .

analyze:
	$(FLUTTER) analyze

## Fast test run (excludes goldens)
test:
	$(FLUTTER) test --exclude-tags golden

## Regenerate golden screenshots after intentional UI changes
goldens:
	$(FLUTTER) test --update-goldens --tags golden

## Full verification — run before declaring any task done
verify:
	./tool/verify.sh

## Scaffold a new feature: make feature NAME=my_feature
feature:
	$(DART) run tool/new_feature.dart $(NAME)

## Run the app (dev flavor)
run:
	$(FLUTTER) run --dart-define=ENV=dev
