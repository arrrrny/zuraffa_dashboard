# Data Model: v6-dashboard-migration

Phase 1 output. Entities are Zorphy `@Zorphy` abstract classes (`$Name`
convention, generated companions committed), value objects included. All
live in the pure-Dart app-facing package under
`packages/zuraffa_dashboard/lib/src/domain/entities/`.

## Entities

### Dashboard

A named, persisted dashboard layout.

| Field   | Type             | Rules                                              |
|---------|------------------|----------------------------------------------------|
| `id`    | `String`         | unique; non-empty; the persistence key             |
| `title` | `String`         | non-empty display name                             |
| `owner` | `String`         | scope owner (e.g. user id); non-empty              |
| `tiles` | `List<DashboardTile>` | ordered; tile ids unique within the dashboard |
| `isDefault` | `bool`       | marks the built-in default layout template         |

State transitions: created (empty or from tiles) → tiles added/removed/
moved/resized → saved (persisted snapshot) → reset (restored to default
template for the owner).

### DashboardTile

One card on a dashboard.

| Field     | Type             | Rules                                        |
|-----------|------------------|----------------------------------------------|
| `id`      | `String`         | unique within its dashboard                  |
| `type`    | `String`         | tile-kind discriminator (e.g. `chart.sales`) |
| `title`   | `String`         | non-empty display name                       |
| `placement` | `TilePlacement`| grid position + span                         |
| `enabled` | `bool`           | disabled tiles render as placeholders        |
| `config`  | `Map<String, Object?>` | opaque JSON-encodable payload          |

### TilePlacement (value object)

| Field     | Type | Rules                                   |
|-----------|------|-----------------------------------------|
| `row`     | `int`| >= 0                                    |
| `column`  | `int`| >= 0                                    |
| `rowSpan` | `int`| >= 1                                    |
| `colSpan` | `int`| >= 1                                    |

Invariants: placement fields non-negative / >= 1 as above; a dashboard
never contains two tiles with the same id (enforced by use cases, not the
entity).

## Contracts (repository / datasource / port)

### DashboardRepository (FR-002)

Zuraffa repository contract over `Dashboard`:

```dart
abstract class DashboardRepository {
  Future<Dashboard> get(QueryParams<Dashboard> params);
  Future<List<Dashboard>> getList(ListQueryParams<Dashboard> params);
  Future<Dashboard> create(Dashboard dashboard);
}
```

`DataDashboardRepository` implements it over the datasource; the datasource
contract (`DashboardDataSource`) exposes get/getList/create backed by
`InMemoryDashboardStore` by default.

### DashboardPort (FR-005)

Technology-agnostic layout persistence:

```dart
abstract class DashboardPort {
  Future<Map<String, List<DashboardTile>>> loadLayouts();
  Future<void> saveLayout(String dashboardId, List<DashboardTile> tiles);
  Future<void> removeLayout(String dashboardId);
  Future<void> removeAll();
}
```

Default: `InMemoryDashboardAdapter`. Platform bridge:
`MethodChannelDashboardAdapter` (platform interface package) →
`ZuraffaDashboardPlatform` (native).

## Use cases (FR-003)

| Use case                 | Params                                  | Output           |
|--------------------------|-----------------------------------------|------------------|
| `CreateDashboardUseCase` | `(id, title, owner)`                    | `Dashboard`      |
| `ListDashboardsUseCase`  | `(owner)`                               | `List<Dashboard>`|
| `GetDashboardUseCase`    | `(id)`                                  | `Dashboard`      |
| `SaveDashboardUseCase`   | `(dashboard)`                           | `void`           |
| `AddTileUseCase`         | `(dashboardId, tile)`                   | `Dashboard`      |
| `RemoveTileUseCase`      | `(dashboardId, tileId)`                 | `Dashboard`      |
| `MoveTileUseCase`        | `(dashboardId, tileId, row, column)`    | `Dashboard`      |
| `ResizeTileUseCase`      | `(dashboardId, tileId, rowSpan, colSpan)` | `Dashboard`    |
| `ResetDashboardUseCase`  | `(dashboardId)`                         | `Dashboard`      |

Error surface: unknown dashboard/tile ids raise typed `ArgumentError`
subclasses from the use case layer (`DashboardNotFoundException`,
`TileNotFoundException`, `DuplicateTileException`); cancel via
`CancelToken` per Zuraffa convention.

## Facade & DI

- `DashboardService(port, repository)` — `create`, `list(owner)`, `get(id)`,
  `addTile`, `removeTile`, `moveTile`, `resizeTile`, `reset`, `save`.
- `registerDashboardDependencies(GetIt getIt, {DashboardPort? port,
  DashboardRepository? repository})` — wires port (platform factory if one
  registered, else in-memory), repository, all nine use cases, and the
  service; `setPlatformDashboardPortFactory(...)` is the federated
  registration seam.
