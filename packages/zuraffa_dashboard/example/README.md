# zuraffa_dashboard example

Example host app for the `zuraffa_dashboard` federated plugin: it
registers the dashboard stack, builds a board, saves it, and lists the
demo user's boards.

## What it demonstrates

- `registerDashboardDependencies` wiring the port, the repository, the
  nine use cases, and the `DashboardService` facade through GetIt.
- The documented host journey in `lib/main.dart` —
  `create` → `addTile` → `moveTile` → `save`.
- Reading the boards back with `DashboardService.list` and rendering them
  in a `FutureBuilder`. The future is cached on the widget, so a rebuild
  does not re-query.
- The in-memory default port: with no platform package registered the
  example runs anywhere, layouts persisting for the process lifetime.

## Run

```sh
flutter pub get
flutter run -d macos   # or any connected device
```

## Test

```sh
flutter test
```

`test/dashboard_flow_test.dart` replays the same journey against a fresh
GetIt container and asserts the saved layout reads back through the port.
