# Contract: Public API surface (`package:zuraffa_dashboard`)

Single import: `package:zuraffa_dashboard/zuraffa_dashboard.dart`.

## Exported symbols (barrel)

- Entities: `Dashboard`, `DashboardTile`, `TilePlacement` (Zorphy classes
  with generated `copyWith`/`toJson`/equality companions).
- Typed errors: `DashboardNotFoundException`, `TileNotFoundException`,
  `DuplicateTileException`.
- Repository: `DashboardRepository` (+ `QueryParams`/`ListQueryParams`
  re-exported from `zuraffa`).
- Port & default: `DashboardPort`, `InMemoryDashboardAdapter`.
- Use cases: `CreateDashboardUseCase`, `ListDashboardsUseCase`,
  `GetDashboardUseCase`, `SaveDashboardUseCase`, `AddTileUseCase`,
  `RemoveTileUseCase`, `MoveTileUseCase`, `ResizeTileUseCase`,
  `ResetDashboardUseCase` (+ their `Params` classes).
- Facade & DI: `DashboardService`, `registerDashboardDependencies`,
  `setPlatformDashboardPortFactory`, `getIt`, `setupDependencies`
  (generated DI index re-export).
- `GetIt` re-export (from `zuraffa`) for host wiring.

## Host integration contract

```dart
final getIt = GetIt.instance;
registerDashboardDependencies(getIt);
final dashboards = getIt<DashboardService>();
final board = await dashboards.create(id: 'main', title: 'Main', owner: userId);
await dashboards.addTile(board.id, tile);
```

- With only the core package, layouts persist in memory for the process
  lifetime.
- Adding any federated package (`zuraffa_dashboard_android/_ios/_macos`)
  switches the default port to the native platform-preferences adapter at
  `registerWith()` time — no host code change.
- Hosts may pass `port:`/`repository:` to `registerDashboardDependencies`
  for custom backends.

## Rules

- The barrel is the only public entrypoint; everything else is `src/`.
- The core package declares NO `flutter` dependency (pure Dart).
- Breaking changes to exported signatures require a major version bump
  (sibling governance).
