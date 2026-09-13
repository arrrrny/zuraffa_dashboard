# Tasks: Migrate `zuraffa_dashboard` to Zuraffa (v6)

**Input**: Design documents from `/specs/001-v6-dashboard-migration/`

**Prerequisites**: plan.md (required), spec.md (required for user stories),
research.md, data-model.md, contracts/

**Tests**: TDD is explicitly requested (spec-whole pipeline) — behavior test
tasks are MANDATORY and ordered before their implementation tasks. The
tdd extension's test-list governs them; tasks below carry them.

**Organization**: Tasks are grouped by user story (US1–US6 from spec.md).

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2)
- Include exact file paths in descriptions

## Path Conventions

Federated-plugin monorepo (plan.md): all package code under `packages/`,
publish tooling under `scripts/`, specs under `specs/`.

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Replace the app scaffold with the sibling repo shape.

- [x] T001 Remove the `zfa setup` app scaffold from the repo root: `lib/main.dart`, `lib/app.dart`, `lib/src/di/`, `lib/src/routing/`, `test/bootstrap_smoke_test.dart`, root `android/`, `ios/`, `linux/`, `macos/`, `web/`, `windows/`, root `pubspec.yaml`, `pubspec.lock`, `build.yaml`, `dart_test.yaml`, `.metadata`, `.zfa.json`, `analysis_options.yaml`
- [x] T002 Create root ecosystem files: `README.md` (package intro + repo layout + quickstart link), `LICENSE` (sibling license text), `CHANGELOG.md` (`## 1.0.0` initial entry), update `.gitignore` for multi-package Dart/Flutter (drop app-only entries, keep `.specify` policy)
- [x] T003 [P] Scaffold `packages/zuraffa_dashboard/` (pure Dart): `pubspec.yaml` per research D8 (name, version 1.0.0, `sdk: ^3.11.0`, deps `zuraffa: ^6.2.2`, `zorphy_annotation: ^2.3.0`, `json_annotation: ^4.12.0`, dev `build_runner`, `json_serializable`, `lints`, `test`, `mutation_test`), `analysis_options.yaml` (sibling copy), `build.yaml` (sibling copy), `CHANGELOG.md`, `LICENSE`, `README.md`
- [x] T004 [P] Scaffold `packages/zuraffa_dashboard_platform_interface/` (Flutter): `pubspec.yaml` (deps `flutter`, `plugin_platform_interface: ^2.1.8`, `zuraffa_dashboard: ^1.0.0`), `CHANGELOG.md`, `LICENSE`, `README.md`
- [x] T005 [P] Scaffold `packages/zuraffa_dashboard_android/` (federated): `pubspec.yaml` (`flutter.plugin.implements: zuraffa_dashboard`, android platform, `dartPluginClass: ZuraffaDashboardAndroid`, package `com.zuraffa.dashboard`), `android/build.gradle`, `android/src/main/AndroidManifest.xml`, `CHANGELOG.md`, `LICENSE`, `README.md`
- [x] T006 [P] Scaffold `packages/zuraffa_dashboard_ios/` (federated): `pubspec.yaml` (ios platform, `pluginClass: ZuraffaDashboardPlugin`, `dartPluginClass: ZuraffaDashboardIOS`), `ios/zuraffa_dashboard_ios.podspec`, `ios/Classes/SwiftZuraffaDashboardPlugin.swift`, `CHANGELOG.md`, `LICENSE`, `README.md`
- [x] T007 [P] Scaffold `packages/zuraffa_dashboard_macos/` (federated): `pubspec.yaml` (macos platform, `pluginClass: ZuraffaDashboardPlugin`, `dartPluginClass: ZuraffaDashboardMacos`), `macos/zuraffa_dashboard_macos.podspec`, `macos/Classes/SwiftZuraffaDashboardPlugin.swift`, `CHANGELOG.md`, `LICENSE`, `README.md`
- [x] T008 [P] Port the sibling publish pipeline: `scripts/prepare_for_publish.sh`, `scripts/publish.sh`, `scripts/push_to_master.sh` with the five-package list (`zuraffa_dashboard`, `zuraffa_dashboard_platform_interface`, `zuraffa_dashboard_android`, `zuraffa_dashboard_ios`, `zuraffa_dashboard_macos`) and write `PUBLISH.md` (workflow per research D7)

**Checkpoint**: Repo root matches `zuraffa_permissions` layout; every
package resolves with `dart/flutter pub get`.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Make the TDD loop runnable and the DI/codegen plumbing present.

- [x] T009 Verify all five packages resolve: `dart pub get` in `packages/zuraffa_dashboard`, `flutter pub get` in the other four (fix any constraint conflicts; keep `dependency_overrides` limited to in-family path overrides like the siblings)
- [x] T010 Refresh the TDD profile for the new layout: update `.specify/memory/tdd-profile.md` via the tdd-setup skill so `cwd` is `packages/zuraffa_dashboard`, runner `dart test`, and every recorded command is actually executed and verified
- [x] T011 Create the barrel `packages/zuraffa_dashboard/lib/zuraffa_dashboard.dart` (library doc per contracts/public-api.md; exports filled as layers land)

**Checkpoint**: `dart test` runs green (empty suite) from
`packages/zuraffa_dashboard`; profile verified.

---

## Phase 3: User Story 2 — Repo exists in the ecosystem shape (Priority: P1) 🎯 MVP

**Goal**: The repository IS a valid federated package set (publishable
shape exists even before behaviors land).

**Independent Test**: `ls packages` shows the five sibling-shaped packages;
each `pub spec publish --dry-run` gets past structure/meta errors except
content expectations covered in US5.

### Implementation for User Story 2

- [x] T012 [US2] Verify sibling-shape parity: diff root layout + per-package layout against `~/Developer/zuraffa_permissions` (same directory categories, same metadata fields); record the parity checklist in the spec's `tdd/` notes. Covers [A5]
- [x] T013 [US2] Remove scaffold leftovers check: `git grep -l "zuraffa_flutter\|A new Flutter project" -- packages` returns nothing (the old app dependencies are gone). Covers [A5]

**Checkpoint**: SC-001 satisfied structurally.

---

## Phase 4: User Story 1 — Consume Dashboards via Zuraffa (Priority: P1) 🎯 MVP

**Goal**: A host app declares dashboards/tiles with Zuraffa patterns and
one DI call.

**Independent Test**: `dart test` behaviors in
`packages/zuraffa_dashboard/test/dashboard_test.dart` — entity rules,
repository round-trips, DI wiring, service journeys (FR-001, FR-002,
FR-004, FR-005).

### Tests for User Story 1 (TDD — write first, prove red) ⚠️

- [x] T014 [P] [US1] Behavior test [U1][U2][U3][U4][U5]: entities construct and enforce invariants (non-empty ids/titles, placement ranges row/column >= 0, rowSpan/colSpan >= 1, JSON round-trip, copyWith/equality) in `packages/zuraffa_dashboard/test/dashboard_test.dart` under `group('entities (FR-001)')`
- [x] T015 [P] [US1] Behavior test [U6][U7][U8]: `DashboardRepository` over `DataDashboardRepository` + `InMemoryDashboardStore` get/getList/create round-trips (owner filter both sides, typed not-found, clear) in the same file under `group('repository (FR-002)')`
- [x] T016 [P] [US1] Behavior test [U12][U13]: `registerDashboardDependencies(getIt)` resolves port (in-memory default), repository, use cases, service; custom `port:` injection wins in `packages/zuraffa_dashboard/test/dashboard_test.dart` under `group('di (FR-004)')`
- [x] T017 [P] [US1] Behavior test [A1]: `DashboardService` journeys — create, list by owner, get, add/remove/move/resize tile, save, reset, restore from a fresh service over the same store — in `group('service (FR-004)')`
- [x] T018 [P] [US1] Behavior test [U9][U10][U11]: `InMemoryDashboardAdapter` load/save/remove/removeAll semantics incl. absent-key loads in `group('port (FR-005)')`

### Implementation for User Story 1

- [x] T019 [US1] Create `TilePlacement` entity [U3] `packages/zuraffa_dashboard/lib/src/domain/entities/tile_placement/tile_placement.dart` (+ generated companions) per data-model.md ranges
- [x] T020 [US1] Create `DashboardTile` entity [U2][U4] `packages/zuraffa_dashboard/lib/src/domain/entities/dashboard_tile/dashboard_tile.dart` (+ companions)
- [x] T021 [US1] Create `Dashboard` entity [U1][U4][U5] `packages/zuraffa_dashboard/lib/src/domain/entities/dashboard/dashboard.dart` (+ companions; unique tile ids documented)
- [x] T022 [US1] Run `dart run build_runner build -d` in `packages/zuraffa_dashboard` [U4][U5]; commit generated `*.zorphy.dart`/`*.g.dart` files
- [x] T023 [US1] Create `DashboardRepository` contract `packages/zuraffa_dashboard/lib/src/domain/repositories/dashboard_repository.dart` (get/getList/create, Zuraffa query params)
- [x] T024 [US1] Create `InMemoryDashboardStore` [U6][U7][U8] `packages/zuraffa_dashboard/lib/src/data/datasources/dashboard_store/in_memory_dashboard_store.dart` + datasource adapter + `DataDashboardRepository` in `packages/zuraffa_dashboard/lib/src/data/repositories/data_dashboard_repository.dart`
- [x] T025 [US1] Create `DashboardPort` `packages/zuraffa_dashboard/lib/src/domain/dashboard_port.dart` and `InMemoryDashboardAdapter` [U9][U10][U11] `packages/zuraffa_dashboard/lib/src/data/dashboard/in_memory_dashboard_adapter.dart`
- [x] T026 [US1] Create `DashboardService` facade + `registerDashboardDependencies` [U12][U13] + `setPlatformDashboardPortFactory` [U29] in `packages/zuraffa_dashboard/lib/src/dashboard_service.dart`; wire generated DI index in `packages/zuraffa_dashboard/lib/src/di/`; complete the barrel exports

**Checkpoint**: US1 fully green on `dart test`; host-consumption contract
from contracts/public-api.md demonstrable.

---

## Phase 5: User Story 3 — Core dashboard logic as Zuraffa use cases (Priority: P1)

**Goal**: Every piece of business logic is a Zuraffa UseCase — no statics.

**Independent Test**: `dart test` behaviors in
`packages/zuraffa_dashboard/test/usecases_test.dart` — nine use cases incl.
typed error paths (FR-003).

### Tests for User Story 3 (TDD — write first, prove red) ⚠️

- [x] T027 [P] [US3] Behavior test [U14][U15][U16]: `CreateDashboardUseCase` (creates, rejects duplicate id), `ListDashboardsUseCase` (filters by owner), `GetDashboardUseCase` (typed `DashboardNotFoundException`) in `packages/zuraffa_dashboard/test/usecases_test.dart`
- [x] T028 [P] [US3] Behavior test [U17][U18][U19][U20]: `AddTileUseCase` (appends, rejects duplicate tile id with `DuplicateTileException`), `RemoveTileUseCase` (`TileNotFoundException`), `MoveTileUseCase`/`ResizeTileUseCase` (update placement; span boundary 1 valid / 0 rejected) in the same file
- [x] T029 [P] [US3] Behavior test [U21][U22]: `SaveDashboardUseCase` (persists through repository + port), `ResetDashboardUseCase` (restores default template) in the same file

### Implementation for User Story 3

- [x] T030 [US3] Create the nine use cases [U14]–[U22] under `packages/zuraffa_dashboard/lib/src/domain/usecases/` per data-model.md signatures (Params classes + `execute(params, cancelToken)`, typed errors in `lib/src/domain/errors/`)
- [x] T031 [US3] Register all nine use cases in the generated DI index [U12]; export from barrel

**Checkpoint**: FR-003 complete; `dart analyze` clean.

---

## Phase 6: User Story 4 — Platform parity (Priority: P1)

**Goal**: android/ios/macos federated implementations behind one contract,
safe default without them.

**Independent Test**: `flutter test` in
`packages/zuraffa_dashboard_platform_interface/test/` — mocked-channel
protocol behaviors; default-instance safety; adapter wire mapping.

### Tests for User Story 4 (TDD — write first, prove red) ⚠️

- [x] T032 [P] [US4] Behavior test [U23][U24][A2]: `DefaultZuraffaDashboardPlatform` returns empty layouts and no-ops (safe default; composed stack answers every call without a platform) in `packages/zuraffa_dashboard_platform_interface/test/platform_interface_test.dart`
- [x] T033 [P] [US4] Behavior test [U25][U26][U27]: `MethodChannelZuraffaDashboard` encodes/decodes every protocol method from contracts/method-channel-protocol.md using `TestDefaultBinaryMessengerBinding` mocked channel; `PlatformException` propagates in `packages/zuraffa_dashboard_platform_interface/test/method_channel_test.dart`
- [x] T034 [P] [US4] Behavior test [U28]: `MethodChannelDashboardAdapter` bridges `ZuraffaDashboardPlatform` onto `DashboardPort` (wire map round-trip, absent ids → empty, unknown wire tiles tolerated) in `packages/zuraffa_dashboard_platform_interface/test/adapter_test.dart`

### Implementation for User Story 4

- [x] T035 [US4] Create `packages/zuraffa_dashboard_platform_interface/lib/src/dashboard_platform_interface.dart` [U23][U24] (`ZuraffaDashboardPlatform` + `DefaultZuraffaDashboardPlatform` + wire constants)
- [x] T036 [US4] Create `packages/zuraffa_dashboard_platform_interface/lib/src/method_channel_zuraffa_dashboard.dart` [U25][U26][U27] (channel driver)
- [x] T037 [US4] Create `packages/zuraffa_dashboard_platform_interface/lib/src/method_channel_dashboard_adapter.dart` [U28] (port bridge) + barrel `lib/zuraffa_dashboard_platform_interface.dart`
- [x] T038 [US4] Wire `registerWith()` [U29] in each federated package's dart entrypoint (`lib/zuraffa_dashboard_android.dart`, `_ios.dart`, `_macos.dart`): set platform instance + `setPlatformDashboardPortFactory`
- [x] T039 [US4] Implement native plugin classes: Kotlin `ZuraffaDashboardPlugin` in `packages/zuraffa_dashboard_android/android/src/main/kotlin/com/zuraffa/dashboard/ZuraffaDashboardPlugin.kt` (SharedPreferences) and Swift plugins in `packages/zuraffa_dashboard_ios/ios/Classes/SwiftZuraffaDashboardPlugin.swift` + `packages/zuraffa_dashboard_macos/macos/Classes/SwiftZuraffaDashboardPlugin.swift` (NSUserDefaults) per contracts/method-channel-protocol.md persistence rules

**Checkpoint**: Platform suite green; default stack safe without any
platform package.

---

## Phase 7: User Story 5 — Publish the federated set (Priority: P2)

**Goal**: All five packages publish-ready under the zuzu.dev workflow.

**Independent Test**: publish dry-run per package exits 0.

- [x] T040 [US5] Make `packages/zuraffa_dashboard` pass `dart pub publish --dry-run` [A3] (metadata, README, CHANGELOG, LICENSE per package; no `publish_to: none`)
- [x] T041 [US5] Make each Flutter package pass `flutter pub publish --dry-run` [A3] (podspec names, plugin declarations, topics, repository/issue_tracker fields)
- [x] T042 [US5] Smoke-verify the scripts [A4]: `bash -n` all three; verify `prepare_for_publish.sh` version-bump sed list matches the five package names; document expected manual steps in `PUBLISH.md`

**Checkpoint**: SC-003 + SC-004 (dry-run green; workflow scripted).

---

## Phase 8: User Story 6 — Easy whole-plugin workflow (Priority: P2)

**Goal**: Checkout → publish-ready is documented and scripted.

- [x] T043 [US6] Finalize root `README.md` [A4] with the one-page workflow: analyze/test per package, dry-run, `PUBLISH.md` pipeline; link specs + example
- [x] T044 [US6] Create the example app `packages/zuraffa_dashboard/example/` (minimal Flutter host: registers stack, creates dashboard, adds + moves a tile, saves/reloads) with `dependency_overrides` to siblings and a `test/dashboard_flow_test.dart` widget test proving the journey
- [x] T045 [US6] Run `specs/001-v6-dashboard-migration/quickstart.md` end-to-end [A1][A2][A3][A4][A5] and fix any divergence it exposes

---

## Phase 9: Polish & Cross-Cutting Concerns

- [x] T046 Run `dart analyze` + full test suites across all packages; fix findings
- [ ] T047 Update spec status frontmatter (`status: implemented`) and record final evidence links in the feature's `tdd/` artifacts

## Final acceptance gates (outer loop green before done)

- [x] T048 [US1] [A1] Final: host-journey acceptance test green in `packages/zuraffa_dashboard/test/dashboard_test.dart`
- [x] T049 [US4] [A2] Final: default-stack safety acceptance test green in `packages/zuraffa_dashboard_platform_interface/test/platform_interface_test.dart`
- [x] T050 [US5] [A3] Final: all five packages green on publish dry-run + `dart analyze`
- [x] T051 [US6] [A4] Final: publish-pipeline contract proof recorded (scripts parse, package list matches)
- [x] T052 [US2] [A5] Final: repo-shape parity proof recorded

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)** → **Foundational (Phase 2)** → stories in priority
  order: US2 (shape) → US1 (core consumption) → US3 (use cases) → US4
  (platform) → US5 (publish) → US6 (workflow) → polish.
- US3 depends on US1 entities/repository; US4 depends on US1 port types;
  US5/US6 depend on everything (they verify the whole).

### Parallel Opportunities

- T003–T008 (independent package scaffolds + scripts)
- T014–T018 (behavior tests, one file each) before their implementations
- T027–T029 and T032–T034 likewise

---

## Implementation Strategy

- MVP = Phases 1–4 (repo shape + core consumption green).
- The tdd loop owns every behavior task above; `speckit-implement` owns the
  rest (scaffolds, native glue, docs, scripts).
- Commit after each phase checkpoint.
