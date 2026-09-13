---
detected_at: 86e4a7f # short SHA the profile was detected against
ecosystems: [dart] # one entry per detected stack
default: dart # which one the loop uses when a path is ambiguous
stacks:
  dart:
    cwd: packages/zuraffa_dashboard # working directory every command below runs in
    runner: "package:test (^1.24.0)"
    single: 'dart test -n "{name}"'
    file: dart test {file}
    suite: dart test
    watch: null # this package:test version has no --watch flag
    coverage: 'dart test --coverage=coverage'
    mutation: 'dart run mutation_test' # mutation_test 1.8.0 in dev deps; see note below
    acceptance: null # no acceptance/e2e tests exist
    property: null # glados not in lock; ecosystem default is `glados`
    approval: null # no snapshot/approval tool in use
    contract: null # no contract tests
    test_glob: "test/**/*_test.dart"
    exemplar: # filled by the loop with its first test file
      unit: test/dashboard_test.dart
    helpers: # test utilities a new test reuses instead of hand-rolling
      - lib/src/data/dashboard/in_memory_dashboard_adapter.dart # in-memory fake reused as the test double for DashboardPort
verified: [single-caveat, file, suite, coverage] # each was run successfully; see notes
suite_baseline: green # empty suite at detection time (0 tests, exit 0)
suite_seconds: 27 # observed wall time incl. first-run compile of an empty suite
---

# TDD Stack Profile

Refreshed for the federated package layout (feature 001-v6-dashboard-migration,
tasks T001–T010). The previous profile targeted the removed app scaffold
(`flutter test` at the repo root); every command below now runs inside the
pure-Dart app-facing package.

## Conventions to match

- Test files live in `test/` and are named `*_test.dart`. The first one is
  `test/dashboard_test.dart`; use-case behaviors live in
  `test/usecases_test.dart` (per tasks.md T014–T018/T027–T029).
- Assertions use `expect` from `package:test` with its built-in matchers:
  `isTrue`, `hasLength`, `contains`, `throwsA`, `isA`, `having`. No custom
  matchers are registered.
- Grouping maps tests to spec acceptance criteria:
  `group('... (FR-XXX)', () { test(...) })`. Keep the `FR-XXX` tag in the
  group name so a test is traceable to `spec.md`.
- Doubles: there is **no mocking library** in the core package. The only
  double pattern is the production `InMemoryDashboardAdapter` /
  `InMemoryDashboardStore` used as fakes. Follow that in-memory-fake pattern
  for every test; do not add a mocking library here.
- DI in tests: build a fresh `GetIt` per test (never share
  `GetIt.instance`) before calling `registerDashboardDependencies`.
- Flutter packages (`_platform_interface`, `_android`, `_ios`, `_macos`) run
  `flutter test` from their own directories; their suites are separate from
  the Dart inner loop. At detection time only the platform interface has
  tests scheduled (tasks T032–T034).

## Notes and constraints

- **Working directory is `packages/zuraffa_dashboard`.** Every command above
  runs from there. Dependencies resolve from pub.dev (`zuraffa: ^6.2.2`);
  generated `*.zorphy.dart`/`*.g.dart` files are committed, so tests run
  without `build_runner`.
- **Empty-suite and no-match behavior (verified).** `dart test` on a
  directory with no test files prints "No tests ran. / No tests were found."
  and exits 0. `dart test -n "{name}"` with a non-matching name behaves the
  same way. The loop MUST treat "No tests ran." as a non-green (red/blocked)
  signal, never as a pass — a mistyped name must not produce a false green.
  Always copy the exact test name from the file.
- **Mutation is installed but not yet verified by running.** `mutation_test
  1.8.0` is a dev dependency; at detection time there is no behavior-bearing
  source under `lib/` to mutate, so the command is recorded from the
  ecosystem default with its first scoped verification run deferred to
  `/speckit.tdd.verify`. Scope runs with explicit file paths (e.g.
  `dart run mutation_test lib/src/domain/usecases/...`); the bare command
  mutates every `.dart` file under `lib/` including generated `*.zorphy.dart`
  / `*.g.dart` — scope to avoid noise.
- **Coverage** runs and exits 0 (trivially, on an empty suite). Raw VM
  coverage JSON lands under `coverage/`.
- **Property-based testing is not installed.** `glados` is absent from the
  lock. Invariants become boundary example tests.
- **Platform wiring (federated).** The three federated packages call
  `setPlatformDashboardPortFactory(() => MethodChannelDashboardAdapter())`
  from their `registerWith()` (Flutter runs this when the app starts). That
  makes `registerDashboardDependencies(getIt)` default to the real
  `MethodChannelDashboardAdapter` once an app depends on a platform package.
  The main package stays pure Dart and defaults to
  `InMemoryDashboardAdapter` when no platform package registered (tests,
  servers), preserving FR-005. The contract types (`DashboardPort`, entities)
  intentionally live in the pure-Dart main package, not in
  `platform_interface`; `platform_interface` depends *down* on the main
  package for them (no cycle).
- **No acceptance / contract / approval layers** exist in this repository.
