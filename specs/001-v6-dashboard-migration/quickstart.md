# Quickstart: validate the zuraffa_dashboard migration

Prerequisites: Flutter 3.41+ / Dart 3.11+ on PATH; this repo cloned.

## 1. Shape check (SC-001)

```bash
ls packages
# → zuraffa_dashboard zuraffa_dashboard_platform_interface
#   zuraffa_dashboard_android zuraffa_dashboard_ios zuraffa_dashboard_macos
ls README.md LICENSE CHANGELOG.md PUBLISH.md scripts specs
```

## 2. Core suite (SC-002)

```bash
cd packages/zuraffa_dashboard
dart pub get
dart test            # → All tests passed! (entity/repo/usecase/service behaviors)
dart analyze         # → No issues found!
```

## 3. Platform interface suite

```bash
cd packages/zuraffa_dashboard_platform_interface
flutter pub get
flutter test         # → All tests passed! (channel contract via mocked channel)
dart analyze
```

## 4. Publish readiness (SC-003)

```bash
cd packages/zuraffa_dashboard                     # repeat for each of the 5 packages
flutter pub publish --dry-run     # or: dart pub publish --dry-run (core)
# → Package has 0 warnings (or only documented IPOA deltas)
```

## 5. Full publish workflow (SC-004, maintainer-only)

See [PUBLISH.md](../../../PUBLISH.md):
`prepare_for_publish.sh <version>` → push branch → `publish.sh` →
`push_to_master.sh -f`. Every step is a shipped script; nothing manual.

## Expected end-to-end proof

The example app (`packages/zuraffa_dashboard/example`) registers the stack,
creates a dashboard, adds/moves a tile, saves, and reloads —
`flutter test` in the example exercises the same journey against the
plugin's default port.
