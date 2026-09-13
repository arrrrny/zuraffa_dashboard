---
feature: 001-v6-dashboard-migration
issue: 673
epic: 214
status: implemented
---

# Feature Specification: Migrate `zuraffa_dashboard` to Zuraffa (v6)

## Summary

Migrate `zuraffa_dashboard` to be built on the **published** Zuraffa
framework (`zuraffa: ^6.x` from pub.dev) as a complete rewrite: restructure
the repository from the current single-app `zfa setup` scaffold into the
federated plugin layout the ecosystem packages use (`zuraffa_auth`,
`zuraffa_permissions`), model the dashboard domain as Zuraffa entities,
route all persistence through Zuraffa datasources/repositories, express all
business logic as Zuraffa use cases, and make the whole federated set —
app-facing package + platform interface + android/ios/macos
implementations — publishable to pub.dev with a one-workflow publish
pipeline.

## Motivation

EPIC #214 migrates every ZikZak pub.dev package onto the Zuraffa v6
framework so they share infrastructure, follow one consistent pattern, and
can be maintained together. `zuraffa_dashboard` (issue #673) currently
exists only as an empty Flutter **app** scaffold created by `zfa setup`
(`pub.dev: 404`); it has no package identity, no federated platform
subpackages, and nothing built on Zuraffa. The sibling capability packages
(`zuraffa_permissions` per issue #668, `zuraffa_auth`) define the target
shape: a monorepo of `packages/` with an app-facing package, a platform
interface package, and per-platform federated implementations, plus
`scripts/` + `PUBLISH.md` as the easy, repeatable publish pipeline.

## User stories

- **US1 (P1)** — Consume Dashboards via Zuraffa: declare dashboards and
  dashboard tiles using Zuraffa's entity/repository/use-case patterns from
  a host Zuraffa app with a single package import + GetIt registration.
- **US2 (P1)** — Repo exists in the ecosystem shape: valid federated
  Dart/Flutter package structure (app-facing package, platform interface,
  android/ios/macos subpackages) replacing the app scaffold.
- **US3 (P1)** — Migrate core dashboard logic to Zuraffa: entity /
  datasource / repository / use-case layers; no Flutter-specific code in
  the core; a technology-agnostic port with a pure-Dart default adapter so
  everything tests without a platform.
- **US4 (P1)** — Platform parity: android, ios, and macos federated
  implementations behind one platform-interface contract, with a typed,
  safe default so hosts without a platform package keep working.
- **US5 (P2)** — Publish the migrated federated set to pub.dev under the
  `zuzu.dev` publisher with the sibling publish pipeline (prepare →
  publish → push-to-master), documented in `PUBLISH.md`.
- **US6 (P2)** — Easy whole-plugin workflow: a contributor can go from
  checkout to "all five packages publish-ready" with the documented
  script workflow (verify, analyze, test, version, publish) — the repo
  itself is the easy way to create/publish the whole plugin.

## Functional requirements

- **FR-001** All dashboard domain types modeled as Zuraffa entities with
  unique identifiers — `Dashboard`, `DashboardTile` (Zorphy `@Zorphy`
  entities) plus typed value objects for tile placement
  (row/column/rowSpan/colSpan) and size.
- **FR-002** All persistence ops through Zuraffa
  datasources/repositories — `DashboardRepository` contract +
  `DataDashboardRepository` implementation + `InMemoryDashboardStore`
  default store.
- **FR-003** All business logic (dashboard lifecycle, tile management,
  layout mutation, reset-to-default) through Zuraffa use cases —
  create/list/get/save dashboard, add/remove/move/resize tile, reset
  dashboard (nine `UseCase` implementations).
- **FR-004** Package compiles without errors; public API fully accessible
  from a host Zuraffa app (single package import + GetIt registration via
  `registerDashboardDependencies`); a `DashboardService` facade covers the
  common journeys.
- **FR-005** One technology-agnostic port (`DashboardPort`) with a
  pure-Dart default adapter (`InMemoryDashboardAdapter`) so the package
  tests and runs without any platform.
- **FR-006** Platform interface package defines the native contract
  (MethodChannel protocol: load/save/remove layout per dashboard id) with
  a default no-op-safe instance; wire values are stable strings mapped to
  typed results.
- **FR-007** Federated android/ios/macos packages implement the contract
  via `registerWith()` (dartPluginClass), native plugin classes, and
  podspec/gradle wiring, exactly like the sibling packages.
- **FR-008** Every package in the set passes `dart pub publish --dry-run`
  (or `flutter pub publish --dry-run` for plugin packages) and `dart
  analyze` clean, with repository/issue-tracker/topics metadata matching
  the siblings.
- **FR-009** The publish pipeline is scripted and documented: root
  `PUBLISH.md` + `scripts/prepare_for_publish.sh`, `scripts/publish.sh`,
  `scripts/push_to_master.sh` covering all five packages in dependency
  order (app-facing → platform interface → android/ios/macos).
- **FR-010** The former app scaffold is either removed or relocated (the
  app-facing package may carry an `example/` app); the repo root matches
  the sibling layout: `README.md`, `LICENSE`, `CHANGELOG.md`,
  `PUBLISH.md`, `packages/`, `scripts/`, `specs/`.

## Hard constraints

- Follow the `zuraffa_permissions` / `zuraffa_auth` repo layout as the
  reference — do not invent a new structure.
- Core app-facing package stays pure Dart (no `flutter` dependency).
- One PR for this spec.
- Do not claim a step passed that was not run.

## Key Entities

- **Dashboard**: a named, persisted dashboard layout owned by a scope
  (e.g. user id); holds ordered tiles; supports reset to a default layout.
- **DashboardTile**: one card on a dashboard — id, type, title, placement
  (row, column, rowSpan, colSpan), enabled flag, opaque config payload.
- **DashboardPort**: technology-agnostic contract for load/save/remove of
  dashboard layouts; platform adapters implement it.

## Success Criteria

- **SC-001** `packages/` contains exactly the five sibling-shaped packages
  and the root carries README/LICENSE/CHANGELOG/PUBLISH.md/scripts/specs.
- **SC-002** The full test suite (`flutter test` / `dart test` per
  package) is green, including migration-shape tests proving the Zuraffa
  entity/repository/use-case structure (FR-001..FR-005).
- **SC-003** All five packages pass publish dry-run and static analysis
  (FR-008) — publish-ready without manual fixes.
- **SC-004** The documented publish workflow (PUBLISH.md) requires no step
  outside the shipped scripts.

## Assumptions

- The dashboard domain scope is layout/tile management (no native
  charting or home-screen widgets in v1); the native side owns **local
  persistence of dashboard layouts** via platform preferences
  (SharedPreferences on Android, NSUserDefaults on iOS/macOS) — the same
  minimal-but-real native concern the siblings expose.
- `zuraffa` is consumed from pub.dev (`^6.x`), not a local path checkout,
  matching the permissions migration's end state.
- Versions start at `1.0.0` for the whole family, like the siblings.
