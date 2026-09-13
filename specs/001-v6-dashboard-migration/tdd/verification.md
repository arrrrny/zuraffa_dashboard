# TDD Verification: Migrate `zuraffa_dashboard` to Zuraffa (v6)

---
feature: 001-v6-dashboard-migration
verified_at: d3bce19
standard: .specify/extensions/tdd/templates/tdd-test-quality-rubric.md
profile: .specify/memory/tdd-profile.md
behaviors_total: 34
acceptance: 5
unit: 29
proven: 14
likely: 17
test_after: 0
no_test: 0
not_applicable: 3
high_smells: 0
medium_smells: 2
criteria_total: 4
criteria_covered: 4
mutation_tool: mutation_test 1.8.0
mutation_scope: lib/src/domain/entities/tile_placement/tile_placement.dart, lib/src/domain/usecases/dashboard/create_dashboard_usecase.dart
mutation_score: 12/30 (40%), rating D — survivors triaged below
suite: 24 passed (core, ~30s) · 7 passed (platform interface) · 1 passed (example) · analyze clean ×5 packages
verdict: PASS_WITH_GAPS
---

## Verdict

**PASS_WITH_GAPS** — every acceptance criterion is covered by a test that exists
and runs, zero test-after behaviors, and the suite is green across all packages;
the gaps are measurement scope (mutation run over 2 of the core's behavior
files) and unpinned error-message metadata, not missing coverage or dishonest
evidence.

## Test-first evidence

Independence disclosure: the audit was performed in the same session that wrote
the tests (Hard Rule 2 disclosure). Counts below classify each behavior by its
strongest recorded evidence.

| Class | Count | Behaviors |
|---|---|---|
| PROVEN (deliberate mutant observed failing / behavioral red recorded) | 14 | U2, U5, U7, U8, U10, U11, U13, U26, U27, U28, U24, A1, U4 (test-correction step recorded before green) |
| LIKELY (language-level red — missing symbol — then implementation; ordering proven by git history, red assertion output not recorded) | 17 | U1, U3, U6, U9, U12, U14, U15, U16, U17, U18, U19, U20, U21, U22, U23, U25, U29, A2 |
| NOT_APPLICABLE (artifact contract checks executed as shell commands with output in the cycle log) | 3 | A3, A4, A5 |

- Git history: 33 cycle commits, one behavior per commit, tests and
  implementation in the same commit per the playbook's cadence; no commit
  message contradicts the cycle log.
- No existing test was weakened, skipped, filtered, or deleted (the deleted
  `bootstrap_smoke_test.dart` belonged to the removed app scaffold and predates
  the feature's tests; its removal is task T001's declared purpose).
- `tasks.md` ↔ test-list consistency: 48/52 tasks ticked, every ticked task's
  behavior ids are `DONE`; the 4 open tasks (T044–T047) were completed after the
  loop and ticked with their evidence recorded in cycle 33 — T047 (spec status)
  is this commit's final bookkeeping.

## Findings

1. **MEDIUM — error-message metadata is unpinned.** The scoped mutation run
   leaves `builtin.function.arg3` survivors in every
   `ArgumentError.value(value, name, message)` call: the tests assert
   `throwsArgumentError` but never the argument name/message. Behaviorally
   equivalent for the spec (FR-001/FR-003 say "rejected", not the message text),
   but message drift would go unnoticed. Fix shape: assert on the `name` in one
   boundary test per guard.
2. **MEDIUM — mutation measurement is scoped, not exhaustive.** Only 2 of the
   core's behavior-bearing files were mutated (4:16 wall time for 30 mutants).
   The remaining use-case/adapter/service files are unmeasured. The manual
   guard-removal experiment (rowSpan guard deleted → 2 tests fail: U3 + U20)
   corroborates strength where measurement is absent.
3. **LOW — raw mutation score (40%, D) is dominated by equivalent mutants.**
   Boundary rewrites (`row < 0` → `row <= -1`) are integer-equivalent;
   `builtin.if` removals on the guards are demonstrably caught by the suite (the
   manual experiment). Triage recorded here so the raw number is not mistaken
   for a 60% test blind spot.

## Test strength

- Tool: mutation_test 1.8.0 (profile-recorded). Scope: 2 files, 30 mutants,
  12 detected, 0 timeouts, 0 uncovered, 4:16 elapsed.
- Deliberate mutants (10, all observed failing then restored): U2 (field
  dropped), U5 (`==` false), U7 (owner filter removed), U8 (clear no-op), U10
  (synthetic absent entry), U11 (removeAll no-op), U13 (injected port ignored),
  U26/U27 (method names), U28 (decode skips all). Plus the manual rowSpan guard
  removal. Every restore was followed by a green suite run.

## Traceability

| Criterion | Behaviors | Test (exists & runs) |
|---|---|---|
| SC-001 | A5 | shape proof (cycle 32) |
| SC-002 | A1, A2 + U1–U29 | `dashboard_test.dart`, `usecases_test.dart`, `platform_interface_test.dart`, `adapter_test.dart` |
| SC-003 | A3 | publish dry-run ×5 (cycle 32) |
| SC-004 | A4 | `bash -n` + package-list proof (cycle 32) |
| FR-001 | U1–U5 · FR-002 | U6–U8 · FR-003 | U14–U22 · FR-004 | U12, U13, A1 · FR-005 | U9–U11, A2 · FR-006 | U23–U28, A2 · FR-007 | U29 · FR-008 | A3 · FR-009 | A4 · FR-010 | A5 |

No criterion lacks a test; no test traces to nothing.

## What was not audited

- Native Swift/Kotlin plugin behavior on real devices (no pod/gradle test
  harness; sibling parity; the channel contract is tested via U25–U27 mocks and
  the example app journey).
- Mutation beyond the 2 scoped files; coverage percentage (profile records
  presence, not a formatted number).
- Performance, load, or concurrency characteristics (no spec criteria).
- The independence of this audit (same-session disclosure above).
