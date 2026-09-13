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

## Cycle 7: U7 getList filters by owner; non-matching owner yields empty

- test: `test/dashboard_test.dart::repository (FR-002) getList filters by
  owner; non-matching owner yields an empty list` (new)
- red: `dart test` -> `Error: Method not found: 'ListQueryParams'` (test
  import gap; fixed the test's zuraffa show clause, then the behavior ran)
- first-run pass (the owner filter shipped with U6's datasource) ->
  deliberate-mutant check: filter body replaced with `return all` ->
  `Expected: an object with length of <1>` failure; restored via git
  checkout, suite green
- green: suite -> 7 passed, 0 failed
- refactor: none needed
- commit: (this commit)

## Cycle 8: U8 store clear() empties every stored dashboard

- test: `test/dashboard_test.dart::repository (FR-002) store clear()
  empties every stored dashboard` (new)
- first-run pass -> deliberate-mutant check: `clear()` body replaced with
  a no-op -> `Expected: empty / Actual: {…}` failure; restored via git
  checkout, suite green
- green: suite -> 8 passed, 0 failed
- refactor: none needed
- commit: (this commit)

## Cycle 9: U9 in-memory adapter save->load round-trips the tile list

- test: `test/dashboard_test.dart::port (FR-005) in-memory adapter save
  then load round-trips the tile list` (new)
- red: `dart test` -> `Error: Method not found: 'InMemoryDashboardAdapter'`
  (after fixing a brace imbalance introduced while appending the test —
  syntax fix, not a green run)
- green: `DashboardPort` contract + `InMemoryDashboardAdapter` (unmodifiable
  snapshot semantics) + barrel export. Suite -> 9 passed, 0 failed
- refactor: fixed a wrong relative import flagged by `dart analyze`
- commit: (this commit)

## Cycle 10: U10 loading an absent dashboard id returns empty without throwing

- test: `test/dashboard_test.dart::port (FR-005) loading an absent
  dashboard id returns an empty map without throwing` (new)
- first-run pass -> deliberate-mutant check: loadLayouts made to return a
  synthetic `{'nope': []}` entry on empty state -> `Expected: empty /
  Actual: {'nope': []}` caught; restored via git checkout
- green: suite -> 10 passed, 0 failed
- refactor: none needed
- commit: (this commit)

## Cycle 11: U11 removeLayout no-op for absent ids; removeAll clears everything

- test: `test/dashboard_test.dart::port (FR-005) removeLayout is a no-op
  for absent ids; removeAll clears everything` (new)
- first-run pass -> deliberate-mutant check: removeAll replaced with a
  no-op -> `Expected: empty` caught; restored via git checkout
- green: suite -> 11 passed, 0 failed; analyze clean
- refactor: none needed
- commit: (this commit)

## Cycle 12: U14 CreateDashboardUseCase creates/persists; duplicate typed; empty fields rejected

- test: `test/usecases_test.dart::create dashboard (FR-003) creates and
  persists; duplicate id fails typed; empty fields rejected` (new file)
- red: `dart test test/usecases_test.dart` -> `Error when reading
  'lib/src/domain/usecases/dashboard/create_dashboard_usecase.dart'` /
  `Method not found: 'CreateDashboardUseCase'` / `Couldn't find constructor
  'CreateDashboardParams'`
- green: `CreateDashboardUseCase` (+ Params) over the repository —
  duplicate id detection via the repository's typed not-found, empty
  id/title/owner rejected with ArgumentError. Suite -> 12 passed, 0 failed
- refactor: removed the test's direct src import once the barrel exported
  the use case (analyze clean)
- commit: (this commit)

## Cycle 13: U15 ListDashboardsUseCase filters by owner; unknown owner empty

- test: `test/usecases_test.dart::list dashboards (FR-003) lists the owner
  dashboards; an unknown owner yields an empty list` (new)
- red: `dart test test/usecases_test.dart` -> 4 compile errors (missing
  `ListDashboardsUseCase` / `ListDashboardsParams`)
- green: `ListDashboardsUseCase` (+ Params) delegating to the repository's
  owner-filtered getList. Suite -> 13 passed, 0 failed
- refactor: removed the direct src import once the barrel exported it
- commit: (this commit)

## Cycle 14: U16 GetDashboardUseCase returns the board; unknown id typed error

- test: `test/usecases_test.dart::get dashboard (FR-003) returns the
  stored board; an unknown id raises the typed error` (new)
- red: `dart test test/usecases_test.dart` -> 3 compile errors (missing
  `GetDashboardUseCase` / `GetDashboardParams`)
- green: `GetDashboardUseCase` (+ Params) delegating to the repository get.
  Suite -> 14 passed, 0 failed; analyze clean
- refactor: none needed
- commit: (this commit)

## Cycle 15: U17 AddTileUseCase appends and persists; duplicate tile id typed

- test: `test/usecases_test.dart::add tile (FR-003) appends the tile and
  persists; duplicate tile id fails typed` (new)
- red: `dart test test/usecases_test.dart` -> `Method not found:
  'AddTileUseCase'` / `'AddTileParams'`
- green: `AddTileUseCase` (+ Params) over the repository — duplicate check
  against the board's tiles, append via copyWith, persist through a new
  repository `update` method (wired through datasource contract + both
  implementations). Suite -> 15 passed, 0 failed; analyze clean
- refactor: none needed
- commit: (this commit)

## Cycle 16: U18 RemoveTileUseCase removes; unknown tile typed error

- test: `test/usecases_test.dart::remove tile (FR-003) removes the tile;
  an unknown tile id raises the typed error` (new)
- red: `dart test test/usecases_test.dart` -> `Method not found:
  'RemoveTileUseCase'` / `Couldn't find constructor 'RemoveTileParams'`
- green: `RemoveTileUseCase` (+ Params) — presence check, filtered copyWith,
  persists via repository update. Suite -> 16 passed, 0 failed; analyze clean
- refactor: none needed
- commit: (this commit)

## Cycle 17: U19 MoveTileUseCase updates row/column; unknown tile typed error

- test: `test/usecases_test.dart::move tile (FR-003) updates row and
  column; an unknown tile raises the typed error` (new)
- red: `dart test test/usecases_test.dart` -> `Method not found:
  'MoveTileUseCase'` / `Couldn't find constructor 'MoveTileParams'`
- green: `MoveTileUseCase` (+ Params) — rebuilds the placement through the
  guarded `TilePlacement.create` (spans preserved), persists via update.
  Suite -> 17 passed, 0 failed
- refactor: dropped an unused import flagged by analyze (clean)
- commit: (this commit)

## Cycle 18: U20 ResizeTileUseCase span boundaries; unknown tile typed error

- test: `test/usecases_test.dart::resize tile (FR-003) updates spans with
  boundary enforcement; unknown tile typed error` (new)
- red: `dart test test/usecases_test.dart` -> `Method not found:
  'ResizeTileUseCase'` / `Couldn't find constructor 'ResizeTileParams'`
- green: `ResizeTileUseCase` (+ Params) — placement rebuilt through
  `TilePlacement.create` (rowSpan 0 rejected, 1 valid), persists via update.
  Suite -> 18 passed, 0 failed; analyze clean
- refactor: none needed
- commit: (this commit)

## Cycle 19: U21 SaveDashboardUseCase persists through repository and port

- test: `test/usecases_test.dart::save dashboard (FR-003) persists the
  board through the repository and the port` (new)
- red: `dart test test/usecases_test.dart` -> `Method not found:
  'SaveDashboardUseCase'` (+ a const-expression slip in the test itself,
  fixed before the implementation run)
- green: `SaveDashboardUseCase` (+ Params) holding repository + port —
  update() mirrors the board's tiles into the port layout snapshot.
  Suite -> 19 passed, 0 failed; analyze clean
- refactor: none needed
- commit: (this commit)

## Cycle 20: U22 ResetDashboardUseCase restores default template; no template clears

- test: `test/usecases_test.dart::reset dashboard (FR-003) restores the
  default template tiles; without a template clears` (new)
- red: `dart test test/usecases_test.dart` -> `Method not found:
  'ResetDashboardUseCase'` / `'ResetDashboardParams'`
- test-logic fix before green: the "no template" scenario wrongly reused an
  owner whose template still existed; rewritten to a board owned by a
  template-less user (the template lookup is per-owner by design)
- green: `ResetDashboardUseCase` (+ Params) — owner's `isDefault` board
  provides the canonical tiles; port layout mirrored. Suite -> 20 passed,
  0 failed; analyze clean
- refactor: none needed
- commit: (this commit)

## Cycle 21: U12 registerDashboardDependencies wires port/repo/9 use cases/service; in-memory default

- test: `test/dashboard_test.dart::di (FR-004) registration wires port,
  repository, use cases, and service; the default port is in-memory` (new)
- red: `dart test` -> `Method not found: 'registerDashboardDependencies'` /
  `'DashboardService' isn't a type`
- green: `DashboardService` facade (all journeys delegating to
  `execute(...)`) + `registerDashboardDependencies` + the
  `setPlatformDashboardPortFactory` seam in `lib/src/di/dashboard_di.dart`
  (sibling registration style); barrel exports. Suite -> 21 passed, 0
  failed
- refactor: dropped unused imports; switched the facade from the `call()`
  (Result-wrapping) syntax to plain `execute()` to keep the facade's
  Future<T> contract
- commit: (this commit)

## Cycle 22: U13 injected port/repository win over the defaults

- test: `test/dashboard_test.dart::di (FR-004) injected port and repository
  win over the defaults` (new)
- first-run pass -> deliberate-mutant check: the registration mutated to
  ignore the injected `port` -> `Expected: true / Actual: <false>` (the
  injected-port identity check) caught; restored via git checkout
- green: suite -> 22 passed, 0 failed; analyze clean
- refactor: none needed
- commit: (this commit)

## Cycle 23: U29 a platform port factory switches the DI default

- test: `test/dashboard_test.dart::di (FR-004) a platform port factory
  switches the DI default` (new)
- red: `dart test` -> `The argument type 'Null' can't be assigned to the
  parameter type 'DashboardPort Function()'` — the test drives the setter
  to accept a nullable factory (passing null clears a factory), needed for
  teardown
- green: setter widened to `DashboardPort Function()?`; factory product
  becomes the registered default port. Suite -> 23 passed, 0 failed;
  analyze clean
- mutant check: `_defaultDashboardPort()` mutated to always return the
  in-memory default -> `Expected: true / Actual: <false>` caught; restored
  (a first restore also reverted the nullable-setter change — re-applied,
  suite re-verified green)
- commit: (this commit)
