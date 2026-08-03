# Flutter Starter

Production-shaped Flutter template: **feature-first + Riverpod + go_router + dio + freezed**,
with flavors, strict lints, and CI.

## Quick start

```bash
fvm install stable && fvm use stable      # pin SDK
fvm flutter pub get                        # deps
dart run build_runner build -d             # codegen (freezed/riverpod/json)
fvm flutter run --dart-define=ENV=dev      # run (dev flavor)
```

## Structure

```
lib/
├── core/                 # cross-cutting: config, theme, router, network
│   ├── config/           # AppConfig — env selection via --dart-define=ENV
│   ├── theme/            # Material 3 light/dark from a seed color
│   ├── router/           # go_router config + not-found handling
│   └── network/          # dio client provider with logging interceptor
├── features/             # one folder per feature
│   └── <feature>/
│       ├── data/         # repositories, data sources, DTOs
│       ├── domain/       # entities, use-cases, repo interfaces
│       ├── application/  # controllers / state (Riverpod)
│       └── presentation/ # screens + widgets
└── main.dart
```

## Flavors / environments

Env is chosen at build time:

```bash
fvm flutter run   --dart-define=ENV=dev
fvm flutter build appbundle --dart-define=ENV=prod
fvm flutter build ipa       --dart-define=ENV=prod
```

## Quality

```bash
fvm flutter analyze          # strict lints (very_good_analysis)
fvm flutter test             # unit + widget tests
```

See **AGENTS.md** for the full new-project checklist as agent-executable directives.
