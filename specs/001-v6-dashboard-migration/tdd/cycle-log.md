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
