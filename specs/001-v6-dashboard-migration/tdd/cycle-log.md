# Cycle Log: Migrate `zuraffa_dashboard` to Zuraffa (v6)

Append only. Newest last. Every entry's `red` block is the evidence that the
test existed and failed before the implementation.

## Baseline

- suite: `flutter test` (repo root, pre-restructure scaffold) -> 1 passed,
  0 failed (`test/bootstrap_smoke_test.dart`)
- commit: `947cdab`
- recorded: cycle 0, before any change
- note: the scaffold suite is scheduled for removal by task T001 (the app
  scaffold it exercises is replaced by the federated package layout); a new
  baseline over `packages/zuraffa_dashboard` (`dart test`, empty suite) is
  recorded after the Foundational phase before the first red.

## Cycle 1: U1 dashboard constructs from required fields and carries them

- test: `test/dashboard_test.dart::entities (FR-001) dashboard constructs
  from required fields and carries them` (new)
- red: `dart test test/dashboard_test.dart`
  -> `Error: Method not found: 'Dashboard'.` (symbol absent; per playbook
  the language-level missing symbol is the pre-stub state — implementation
  declared the entity and its companions, then this test ran to green)
- green: entity `$Dashboard` annotated `@Zorphy(generateCompareTo: true)` +
  codegen (`dart run build_runner build`); `DashboardTile`/`TilePlacement`
  declared as plain stubs so the signature resolves (their behaviors are
  U2/U3). Suite `dart test` -> 1 passed, 0 failed; `dart analyze` clean
- refactor: none needed
- commit: (this commit)

## Cycle 2: U2 dashboard tile constructs from required fields and carries them

- test: `test/dashboard_test.dart::entities (FR-001) dashboard tile
  constructs from required fields and carries them` (new)
- first-run pass -> deliberate-mutant check: replaced the initializing
  formal `required this.enabled` with `bool? enabled` + `: enabled = false`
  -> `Expected: true / Actual: <false>` (test fails for the right reason);
  restored exactly via `git checkout --`. Note: a first mutant attempt
  (`enabled = false` initializer) was a compile error and an earlier sed
  silently did not apply — both discarded, the recorded mutant is the
  behavioral one above.
- green: suite `dart test` -> 2 passed, 0 failed
- refactor: upgraded the U1-cycle declaration stub to the real Zorphy
  entity (`@Zorphy(generateCompareTo: true)` + codegen, hand stub removed);
  suite re-run green after the upgrade
- commit: (this commit)

## Cycle 3: U3 tile placement guards its boundaries on construction

- test: `test/dashboard_test.dart::entities (FR-001) tile placement guards
  its boundaries on construction` (new)
- red: `dart test` -> `Error: Member not found: 'TilePlacement.create'.`
- green: added the static `TilePlacement.create` guard (row/column >= 0,
  rowSpan/colSpan >= 1; both sides of each boundary asserted). Suite ->
  3 passed, 0 failed; analyze clean
- refactor: none needed
- commit: (this commit)

## Cycle 4: U4 entities round-trip through JSON

- test: `test/dashboard_test.dart::entities (FR-001) entities round-trip
  through JSON` (new)
- red: `dart test` -> `Error: Member not found: 'TilePlacement.fromJson'` /
  `'DashboardTile.fromJson'` / `'Dashboard.fromJson'`
- implementation: `generateJson: true` on all three entities + `*.g.dart`
  parts + regen; TilePlacement upgraded from the U1-cycle stub to the full
  Zorphy value object (the `create` guard moved onto the abstract class)
- test correction (its own step, before green, stated reason): the initial
  whole-object equality assertions failed because zorphy's generated `==`
  compares collections by identity (`tiles == other.tiles`), the ecosystem
  codegen idiom. Replaced with field-wise round-trip assertions pinning
  every field (row 2/column 3/rowSpan 1/colSpan 2, config payload, nested
  placement) — same behavior, observable field by field; nothing weakened.
- green: suite `dart test` -> 4 passed, 0 failed; analyze clean
- refactor: none needed
- commit: (this commit)

## Cycle 5: U5 companions — copyWith targets one field; equal instances compare equal

- test: `test/dashboard_test.dart::entities (FR-001) companions: copyWith
  changes only the targeted field and equal instances compare equal` (new)
- first-run pass (copyWith/equality are zorphy-generated) -> deliberate-
  mutant check: `operator ==` in tile_placement.zorphy.dart made
  `return false` after the identical() guard -> `Expected: TilePlacement<…>
  Actual: TilePlacement<…>` failure caught by the test; restored via
  `git checkout --`, suite green again
- green: suite `dart test` -> 5 passed, 0 failed; analyze clean
- refactor: none needed
- commit: (this commit)

## Cycle 6: U6 repository create->get; unknown id raises typed not-found

- test: `test/dashboard_test.dart::repository (FR-002) create then get
  returns the stored dashboard; unknown id raises typed not-found` (new)
- red: `dart test` -> `Method not found: 'InMemoryDashboardStore'` /
  `'InMemoryDashboardDataSource'` / `'DataDashboardRepository'` /
  `'DashboardNotFoundException' isn't a type`
- green: added the typed error subclasses (ZuraffaPlatformException with
  stable codes), `DashboardDataSource` contract, `InMemoryDashboardStore`
  + `InMemoryDashboardDataSource` (sibling mixin idiom: with Loggable,
  FailureHandler), `DashboardRepository`, `DataDashboardRepository`, and
  the barrel exports. Suite -> 6 passed, 0 failed; analyze clean
- refactor: none needed
- commit: (this commit)
