# Research: v6-dashboard-migration

Phase 0 output — every decision below resolves a design question raised by
the spec. Reference for all decisions: the `zuraffa_permissions` repo
(migrated and published under the same EPIC, issue #668) and the
`zuraffa_auth` repo.

## D1 — Repo layout: federated monorepo vs single plugin package

- **Decision**: Federated monorepo — `packages/zuraffa_dashboard` +
  `_platform_interface` + `_android` + `_ios` + `_macos`, with root
  `PUBLISH.md`, `scripts/`, `specs/`.
- **Rationale**: The user's instruction is explicit ("follow the
  zuraffa_auth, zuraffa_permission and other packages … publish to pub dev
  with ios,macos,android subpackages") and the sibling repos are the
  approved, already-published precedent.
- **Alternatives considered**: Single `flutter create --template=plugin`
  package with in-package platform dirs (current scaffold shape) — rejected:
  not the ecosystem pattern; platform code cannot version/publish
  independently; EPIC #214 requires the sibling shape.

## D2 — zuraffa source: pub.dev version vs local path

- **Decision**: `zuraffa: ^6.2.2` from pub.dev (same as the permissions
  migration's end state). No `dependency_overrides` for zuraffa.
- **Rationale**: FR: "built on the published Zuraffa framework"; siblings
  publish with the pub.dev constraint. Pub ignores `dependency_overrides`
  at publish time, but keeping dev checkouts out of the manifest keeps the
  dry-run honest.
- **Alternatives considered**: `--zuraffa-path`-style local override —
  rejected for the published manifest (would recreate the pre-migration
  problem #673 exists to fix).

## D3 — Entity codegen: Zorphy

- **Decision**: Entities are `@Zorphy` classes with generated
  `*.zorphy.dart` companions via `build_runner` (`zorphy:zorphy` +
  `json_serializable` + `combining_builder`, exactly the sibling
  `build.yaml`). Generated files are committed.
- **Rationale**: FR-001 mandates Zuraffa/Zorphy entities; committing
  generated files keeps `dart test` runnable from cold clone without a
  codegen step (the sibling suite's property).
- **Alternatives considered**: Hand-written immutables — rejected (breaks
  the FR-001 entity mandate); freezed — rejected (not the ecosystem
  toolchain).

## D4 — Native concern behind the platform channel

- **Decision**: Local persistence of dashboard layouts via platform
  preferences: SharedPreferences (Android), NSUserDefaults (iOS/macOS).
  Channel protocol: `loadLayouts`, `saveLayout`, `removeLayout`,
  `removeAll` (see contracts/method-channel-protocol.md).
- **Rationale**: A dashboard package's native value is surviving app
  restarts without forcing a backend on consumers; preferences are the
  smallest real native concern, implementable/testable on all three
  platforms, and mirror the siblings' "one small real native capability"
  scope.
- **Alternatives considered**: Home-screen widgets — rejected (huge native
  surface, not in v1 spec assumptions); native chart rendering — rejected
  (out of spec scope); no native side at all (Dart-only) — rejected: the
  user explicitly requires ios/macos/android subpackages, and a federated
  package set without any native capability would be dead weight.

## D5 — Port & adapter seam

- **Decision**: `DashboardPort` (load/save/remove, typed results) in the
  pure-Dart core; `InMemoryDashboardAdapter` as the default; the platform
  interface package provides `MethodChannelDashboardAdapter` bridging
  `ZuraffaDashboardPlatform` onto the port; federated packages call
  `registerWith()` → set `ZuraffaDashboardPlatform.instance` +
  `setPlatformDashboardPortFactory(...)`; `registerDashboardDependencies`
  defaults to the platform factory when one registered, else in-memory.
  Contract types live in the core package; the platform interface depends
  down on the core (no cycle) — the exact permissions pattern.
- **Rationale**: FR-005/FR-006; keeps the inner loop on `dart test` with a
  pure-Dart fake, and hosts without a platform package fully functional.
- **Alternatives considered**: Port in the platform interface — rejected
  (creates a Flutter dependency in core or a contract split that the
  siblings deliberately avoided).

## D6 — Use case set (nine)

- **Decision**: `CreateDashboardUseCase`, `ListDashboardsUseCase`,
  `GetDashboardUseCase`, `SaveDashboardUseCase` (persists layout),
  `AddTileUseCase`, `RemoveTileUseCase`, `MoveTileUseCase`,
  `ResizeTileUseCase`, `ResetDashboardUseCase` — all extend Zuraffa's
  `UseCase<Output, Params>` with `execute(params, cancelToken)`.
- **Rationale**: FR-003 names exactly these capabilities; nine matches the
  sibling granularity (one behavior per use case).
- **Alternatives considered**: A single mutable `DashboardEditor` —
  rejected (static-utility shape the migration exists to remove).

## D7 — Publish pipeline

- **Decision**: Port the three sibling scripts verbatim with the package
  list swapped: `prepare_for_publish.sh <version>` (publish branch, bump
  five packages + in-family constraints, propagate CHANGELOG),
  `publish.sh` (dry-run + publish in dependency order with propagation
  waits), `push_to_master.sh -f`. `PUBLISH.md` documents the workflow.
- **Rationale**: FR-009/US6 — "easy way … to publish to pub dev" is the
  sibling workflow; reusing it verbatim keeps every repo's release muscle
  memory identical.
- **Alternatives considered**: A new `zfa` CLI command for scaffolding
  federated plugins — investigated: `zfa package create` scaffolds a single
  package and `zfa module` scaffolds app feature packages; NEITHER creates
  the federated set. Adding one is a zuraffa-repo feature (out of this
  repo's scope); noted as a follow-up in the final report.

## D8 — Naming/versions metadata

- **Decision**: Package names as in D1; all versions `1.0.0`;
  `homepage: https://zuraffa.com`; `repository`/`issue_tracker` point at
  `github.com/arrrrny/zuraffa_dashboard`; topics `dashboard`,
  `clean-architecture`, `zuraffa`, `state` (+ per-platform topics on the
  federated packages). SDK constraints: core `sdk: ^3.11.0`; flutter
  packages `sdk: ^3.11.0` + `flutter: >=3.41.0` (sibling parity).
- **Rationale**: Sibling parity; pub.dev required metadata for a
  credible dry-run.

## D9 — Test stack split

- **Decision**: Core package tests run on `dart test`
  (`test/dashboard_test.dart` + `test/zuraffa_migration_test.dart` shape);
  the platform interface package gets a `flutter_test` suite that drives
  the MethodChannel implementation with a mocked channel; federated
  packages ship without test dirs at v1 (sibling parity — their behavior
  is the Swift/Kotlin glue verified by the example app + channel
  contract tests); the example app hosts an outcome-matrix widget test.
- **Rationale**: Mirrors the sibling test topology and keeps red/green
  loop latency low; the tdd-profile refresh will encode it.
- **Alternatives considered**: Integration tests on device farms —
  deferred (not in this spec's success criteria).
