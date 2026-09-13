# Test List: Migrate `zuraffa_dashboard` to Zuraffa (v6)

---
feature: 001-v6-dashboard-migration
loop: outside-in
profile: .specify/memory/tdd-profile.md
spec_criteria: 4
planned_at: 947cdab
updated_at: 947cdab
suite_baseline: green
---

## Outer loop: acceptance behaviors

One per success criterion in `spec.md`. The feature's real entry points are
the package public API and the publish pipeline; the profile has no dedicated
acceptance runner, so A1/A2 run as integration-style suites over the composed
modules (the highest level this repo can test) and A3–A5 run as contract
checks over the shipped artifacts.

| id  | behavior                                                                                                                                         | traces          | kind     | state   | test                                                              |
| --- | ------------------------------------------------------------------------------------------------------------------------------------------------ | --------------- | -------- | ------- | ----------------------------------------------------------------- |
| A1  | A host completes a full dashboard journey through the public API only: `registerDashboardDependencies(getIt)` → create → addTile → moveTile → save → a fresh service over the same store restores the moved layout | SC-002, FR-004 | example  | PENDING | `packages/zuraffa_dashboard/test/dashboard_test.dart`            |
| A2  | Without any platform package registered, the composed stack works on the in-memory default and the default platform instance answers every call without crashing | SC-002, FR-005, FR-006 | example | PENDING | `packages/zuraffa_dashboard_platform_interface/test/platform_interface_test.dart` |
| A3  | Each of the five packages passes publish dry-run with `dart analyze` clean                                                                        | SC-003, FR-008  | contract | PENDING | `flutter/dart pub publish --dry-run` per package (quickstart §4)  |
| A4  | The publish pipeline is scripted: the three scripts exist, parse, and carry exactly the five package names in dependency order                     | SC-004, FR-009  | contract | PENDING | `bash -n` + package-list check (quickstart §5)                    |
| A5  | Repo shape parity: five sibling-shaped packages under `packages/` plus root README/LICENSE/CHANGELOG/PUBLISH.md/scripts/specs                      | SC-001, FR-010  | example  | PENDING | shape check (quickstart §1)                                       |

## Inner loop: unit behaviors

### `packages/zuraffa_dashboard/lib/src/domain/entities/` (FR-001)

| id  | behavior                                                                                      | traces     | kind             | state   | test |
| --- | --------------------------------------------------------------------------------------------- | ---------- | ---------------- | ------- | ---- |
| U1  | `Dashboard` constructs from required fields; empty id/title/owner are rejected                | FR-001     | example          | PENDING |      |
| U2  | `DashboardTile` constructs from required fields; empty id/type/title are rejected             | FR-001     | example          | PENDING |      |
| U3  | `TilePlacement` boundaries: row/column 0 valid and −1 rejected; rowSpan/colSpan 1 valid and 0 rejected | FR-001 | example          | PENDING |      |
| U4  | JSON round-trip preserves all three entities (sampled at field boundaries; no property lib installed) | FR-001 | property (sampled) | PENDING |      |
| U5  | Zorphy companions hold identity semantics: copyWith changes only the targeted field; equal instances compare equal | FR-001 | example     | PENDING |      |

### `packages/zuraffa_dashboard/lib/src/data/` (FR-002)

| id  | behavior                                                                                      | traces     | kind             | state   | test |
| --- | --------------------------------------------------------------------------------------------- | ---------- | ---------------- | ------- | ---- |
| U6  | Repository create→get returns the stored dashboard; unknown id raises the typed not-found error | FR-002    | example          | PENDING |      |
| U7  | Repository getList filters by owner; a non-matching owner returns an empty list (both sides)  | FR-002     | example          | PENDING |      |
| U8  | `InMemoryDashboardStore.clear()` empties every stored dashboard                               | FR-002     | example          | PENDING |      |

### `packages/zuraffa_dashboard/lib/src/data/dashboard/` (FR-005)

| id  | behavior                                                                                      | traces     | kind             | state   | test |
| --- | --------------------------------------------------------------------------------------------- | ---------- | ---------------- | ------- | ---- |
| U9  | `InMemoryDashboardAdapter` save→load round-trips the tile list                                | FR-005     | example          | PENDING |      |
| U10 | Loading an absent dashboard id returns an empty result without throwing                       | FR-005     | example          | PENDING |      |
| U11 | `removeLayout` is a no-op for an absent id; `removeAll` clears every layout                   | FR-005     | example          | PENDING |      |

### `packages/zuraffa_dashboard/lib/src/dashboard_service.dart` (FR-004, FR-007)

| id  | behavior                                                                                      | traces     | kind             | state   | test |
| --- | --------------------------------------------------------------------------------------------- | ---------- | ---------------- | ------- | ---- |
| U12 | `registerDashboardDependencies(getIt)` resolves port, repository, all nine use cases, and the service; the default port is `InMemoryDashboardAdapter` | FR-004 | example     | PENDING |      |
| U13 | Injected `port:`/`repository:` arguments win over the defaults                                | FR-004     | example          | PENDING |      |
| U29 | `setPlatformDashboardPortFactory(...)` switches the DI default port to the registered factory's product | FR-007 | example     | PENDING |      |

### `packages/zuraffa_dashboard/lib/src/domain/usecases/` (FR-003)

| id  | behavior                                                                                      | traces     | kind             | state   | test |
| --- | --------------------------------------------------------------------------------------------- | ---------- | ---------------- | ------- | ---- |
| U14 | `CreateDashboardUseCase` creates and persists; a duplicate id fails typed                     | FR-003     | example          | PENDING |      |
| U15 | `ListDashboardsUseCase` filters by owner; an unknown owner yields an empty list               | FR-003     | example          | PENDING |      |
| U16 | `GetDashboardUseCase` raises `DashboardNotFoundException` for an unknown id                    | FR-003     | example          | PENDING |      |
| U17 | `AddTileUseCase` appends the tile; a duplicate tile id raises `DuplicateTileException`        | FR-003     | example          | PENDING |      |
| U18 | `RemoveTileUseCase` removes the tile; an unknown tile id raises `TileNotFoundException`       | FR-003     | example          | PENDING |      |
| U19 | `MoveTileUseCase` updates row and column; an unknown tile id raises `TileNotFoundException`   | FR-003     | example          | PENDING |      |
| U20 | `ResizeTileUseCase` updates spans (span 1 valid, 0 rejected); unknown tile → `TileNotFoundException` | FR-003 | example          | PENDING |      |
| U21 | `SaveDashboardUseCase` persists through the repository and the port                           | FR-003     | example          | PENDING |      |
| U22 | `ResetDashboardUseCase` restores the default template tiles for the dashboard                 | FR-003     | example          | PENDING |      |

### `packages/zuraffa_dashboard_platform_interface/lib/src/` (FR-006, FR-007)

| id  | behavior                                                                                      | traces     | kind             | state   | test |
| --- | --------------------------------------------------------------------------------------------- | ---------- | ---------------- | ------- | ---- |
| U23 | `DefaultZuraffaDashboardPlatform.loadLayouts` returns an empty map (safe default)             | FR-006     | example          | PENDING |      |
| U24 | Default save/remove/removeAll complete without error (no-ops)                                 | FR-006     | example          | PENDING |      |
| U25 | `MethodChannelZuraffaDashboard.loadLayouts` decodes the wire map into per-id tile lists (contract) | FR-006 | contract         | PENDING |      |
| U26 | `saveLayout` sends the documented method name with `[id, tiles]` arguments (contract)         | FR-006     | contract         | PENDING |      |
| U27 | `removeLayout`/`removeAll` send their documented method names; a native `PlatformException` propagates (contract) | FR-006 | contract  | PENDING |      |
| U28 | `MethodChannelDashboardAdapter` maps wire→typed and typed→wire; unknown wire tiles degrade to an empty result, never a crash | FR-006 | example | PENDING |      |

## Invariants and edge cases still to place

- None currently unplaced.

## Out of scope

- Unit tests inside the native Swift/Kotlin plugin classes: the sibling
  packages carry no pod/gradle test harness; their glue is exercised through
  the channel contract tests (U25–U27) and the example app (task T044).
- A dedicated end-to-end acceptance runner (device farm): no requirement in
  this spec's success criteria; A1/A2 are the highest-level tests the repo
  can run honestly.
- Home-screen widgets / native charting: excluded by the spec's assumptions
  (v1 scope is layout/tile management with platform-preferences persistence).

## Verification commands

Copied verbatim from `.specify/memory/tdd-profile.md` at planning time, so
this file is readable on its own. **NOTE**: the profile on disk still
targets the pre-restructure app scaffold; task T010 refreshes it. The
post-refresh commands this list will use:

- Single test: `dart test -n "{name}"` (cwd `packages/zuraffa_dashboard`)
- Whole file: `dart test {file}` / `flutter test {file}`
- Full suite: `dart test` (core) / `flutter test` (per Flutter package)
- Coverage: `dart test --coverage=coverage`
- Mutation: `dart run mutation_test <files>`

> The loop MUST treat "No tests ran." (exit 0 from a non-matching
> `dart test -n`) as non-green, never as a pass.
