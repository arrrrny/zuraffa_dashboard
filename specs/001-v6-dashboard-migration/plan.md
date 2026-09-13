# Implementation Plan: Migrate `zuraffa_dashboard` to Zuraffa (v6)

**Branch**: `001-v6-dashboard-migration` | **Date**: 2026-09-13 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/001-v6-dashboard-migration/spec.md`

## Summary

Complete rewrite of `zuraffa_dashboard` from the current empty Flutter app
scaffold (`zfa setup` output) into the ecosystem's federated plugin monorepo
shape, mirroring `zuraffa_permissions` (issue #668) and `zuraffa_auth`: an
app-facing pure-Dart package (Zuraffa entities → datasources/repositories →
use cases → service facade + GetIt registration), a `plugin_platform_interface`
package defining the native MethodChannel contract, and android/ios/macos
federated implementations — all publishable to pub.dev via the scripted
sibling publish pipeline (`PUBLISH.md` + `scripts/`).

## Technical Context

**Language/Version**: Dart SDK ^3.11.0 (core), Flutter >=3.41.0 (platform
packages + example) — matches the sibling packages.

**Primary Dependencies**: `zuraffa: ^6.2.2` (published, pub.dev), 
`zorphy_annotation: ^2.3.0` + `zorphy` builder (entities), 
`json_annotation`/`json_serializable` (payload serialization), 
`plugin_platform_interface: ^2.1.8` (platform interface package), GetIt
(re-exported by `zuraffa`).

**Storage**: in-memory default store (`InMemoryDashboardStore`); native
platform-preferences persistence (SharedPreferences on Android,
NSUserDefaults on iOS/macOS) behind the MethodChannel contract.

**Testing**: `dart test` (app-facing core, pure Dart) + `flutter_test`
(platform packages, method-channel mocks). Mutation testing via
`mutation_test` (opt-in per profile).

**Target Platform**: host Zuraffa Flutter apps on Android/iOS/macOS; the
core package itself is pure Dart (any Dart SDK target).

**Project Type**: federated Flutter plugin monorepo (5 packages + example
app under `packages/`).

**Performance Goals**: none beyond sibling parity (library package).

**Constraints**: core package MUST NOT depend on Flutter; every package
MUST pass `dart analyze` clean and publish dry-run; suite green from cold
clone without codegen hacks.

**Scale/Scope**: 5 packages, ~9 use cases, 2 primary entities, 1 platform
channel, 3 publish scripts.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

The project constitution (`.specify/memory/constitution.md`) is still the
unfilled template — no active project-specific gates. The TDD principle is
added to the constitution by `/skill:speckit-tdd-setup` (extension-managed).
Two de-facto gates carried from the spec's Hard Constraints:

- **Sibling-layout fidelity**: structure must mirror `zuraffa_permissions`;
  PASS (plan adopts the exact layout, see Project Structure).
- **Honest verification**: no step may be claimed passed without running;
  PASS (loop evidence discipline + publish dry-run gates).

## Project Structure

### Documentation (this feature)

```text
specs/001-v6-dashboard-migration/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output
│   ├── public-api.md            # app-facing package API surface
│   └── method-channel-protocol.md # native wire contract
└── tasks.md             # Phase 2 output (speckit-tasks)
```

### Source Code (repository root)

```text
zuraffa_dashboard/                     # repo root (sibling layout)
├── README.md                          # ecosystem-facing readme
├── LICENSE
├── CHANGELOG.md
├── PUBLISH.md                         # publish workflow doc (sibling pattern)
├── packages/
│   ├── zuraffa_dashboard/             # app-facing package (PURE DART)
│   │   ├── pubspec.yaml               # zuraffa ^6.2.2, zorphy_annotation, json_annotation
│   │   ├── analysis_options.yaml
│   │   ├── build.yaml                 # zorphy + json_serializable builders
│   │   ├── CHANGELOG.md
│   │   ├── LICENSE
│   │   ├── README.md
│   │   ├── lib/
│   │   │   └── zuraffa_dashboard.dart # single export barrel
│   │   │   └── src/
│   │   │       ├── domain/
│   │   │       │   ├── entities/dashboard/dashboard.dart          # @Zorphy
│   │   │       │   ├── entities/dashboard_tile/dashboard_tile.dart# @Zorphy
│   │   │       │   ├── entities/tile_placement/tile_placement.dart# @Zorphy
│   │   │       │   ├── repositories/dashboard_repository.dart
│   │   │       │   └── usecases/…                                 # 9 use cases
│   │   │       ├── data/
│   │   │       │   ├── datasources/dashboard_store/in_memory_dashboard_store.dart
│   │   │       │   ├── repositories/data_dashboard_repository.dart
│   │   │       │   └── dashboard/in_memory_dashboard_adapter.dart
│   │   │       ├── di/                # GENERATED DI index + setupDependencies
│   │   │       └── dashboard_service.dart  # facade + registerDashboardDependencies
│   │   ├── test/                      # dart test — behaviors (FR-001..FR-005)
│   │   └── example/                   # Flutter example app (host integration proof)
│   ├── zuraffa_dashboard_platform_interface/   # flutter package
│   │   ├── pubspec.yaml               # plugin_platform_interface, zuraffa_dashboard
│   │   └── lib/src/                   # DashboardPlatform + wire + MethodChannel impl
│   ├── zuraffa_dashboard_android/     # federated android (dartPluginClass + Kotlin-free gradle)
│   ├── zuraffa_dashboard_ios/         # federated ios (podspec + Swift plugin)
│   └── zuraffa_dashboard_macos/       # federated macos (podspec + Swift plugin)
├── scripts/
│   ├── prepare_for_publish.sh         # version bump branch (sibling port)
│   ├── publish.sh                     # dry-run + publish in dependency order
│   └── push_to_master.sh              # merge + tag
└── specs/                             # spec-kit features (this feature lives here)
```

Removed from the current root: the `zfa setup` app scaffold (`lib/main.dart`,
`lib/app.dart`, root `android/ ios/ linux/ macos/ web/ windows/`, root
`pubspec.yaml`, `test/bootstrap_smoke_test.dart`, `.zfa.json` plugin
defaults stay only if still accurate). The example app moves under
`packages/zuraffa_dashboard/example/`.

**Structure Decision**: Option 1 variant — federated-plugin monorepo copied
from the `zuraffa_permissions` layout (the ecosystem's approved pattern per
EPIC #214 and issue #668). The app-facing package stays pure Dart so the
inner TDD loop runs on `dart test`; platform packages are exercised through
the platform interface's default instance + mocked channels.

## Complexity Tracking

> No constitution violations to justify.

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| (none) | | |
