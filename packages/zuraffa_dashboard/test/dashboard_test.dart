import 'package:test/test.dart';
import 'package:zuraffa_dashboard/zuraffa_dashboard.dart';

/// Named identifiers reused across tests so a typo fails a compile rather
/// than a silent mismatch.
const kMain = 'main';
const kOwner = 'user-1';
const kTile = 'tile.sales';

/// Feature `001-v6-dashboard-migration` — the Zuraffa entity / repository /
/// use-case / DI surface of the dashboard package (pure Dart).
void main() {
  group('entities (FR-001)', () {
    test('dashboard constructs from required fields and carries them', () {
      final dashboard = Dashboard(
        id: kMain,
        title: 'Main',
        owner: kOwner,
        tiles: const [],
        isDefault: true,
      );
      expect(dashboard.id, kMain, reason: 'id is carried');
      expect(dashboard.title, 'Main', reason: 'title is carried');
      expect(dashboard.owner, kOwner, reason: 'owner is carried');
      expect(dashboard.tiles, isEmpty, reason: 'tiles default empty here');
      expect(dashboard.isDefault, isTrue, reason: 'isDefault is carried');
    });

    test('dashboard tile constructs from required fields and carries them',
        () {
      final placement = TilePlacement(
        row: 0,
        column: 0,
        rowSpan: 1,
        colSpan: 2,
      );
      final tile = DashboardTile(
        id: kTile,
        type: 'chart.sales',
        title: 'Sales',
        placement: placement,
        enabled: true,
        config: {'metric': 'revenue'},
      );
      expect(tile.id, kTile, reason: 'id is carried');
      expect(tile.type, 'chart.sales', reason: 'type is carried');
      expect(tile.title, 'Sales', reason: 'title is carried');
      expect(tile.placement, same(placement), reason: 'placement is carried');
      expect(tile.enabled, isTrue, reason: 'enabled is carried');
      expect(tile.config['metric'], 'revenue', reason: 'config is carried');
    });

    test('tile placement guards its boundaries on construction', () {
      final atOrigin = TilePlacement.create(
        row: 0,
        column: 0,
        rowSpan: 1,
        colSpan: 1,
      );
      expect(atOrigin.row, 0, reason: 'row 0 is the top boundary and valid');
      expect(atOrigin.column, 0, reason: 'column 0 is the left boundary');
      expect(atOrigin.rowSpan, 1, reason: 'rowSpan 1 is the minimum');
      expect(atOrigin.colSpan, 1, reason: 'colSpan 1 is the minimum');

      expect(
        () => TilePlacement.create(
          row: -1,
          column: 0,
          rowSpan: 1,
          colSpan: 1,
        ),
        throwsArgumentError,
        reason: 'row below 0 is rejected',
      );
      expect(
        () => TilePlacement.create(
          row: 0,
          column: -1,
          rowSpan: 1,
          colSpan: 1,
        ),
        throwsArgumentError,
        reason: 'column below 0 is rejected',
      );
      expect(
        () => TilePlacement.create(
          row: 0,
          column: 0,
          rowSpan: 0,
          colSpan: 1,
        ),
        throwsArgumentError,
        reason: 'rowSpan 0 is below the minimum 1',
      );
      expect(
        () => TilePlacement.create(
          row: 0,
          column: 0,
          rowSpan: 1,
          colSpan: 0,
        ),
        throwsArgumentError,
        reason: 'colSpan 0 is below the minimum 1',
      );
    });

    test('entities round-trip through JSON', () {
      final placement = TilePlacement.create(
        row: 2,
        column: 3,
        rowSpan: 1,
        colSpan: 2,
      );
      final tile = DashboardTile(
        id: kTile,
        type: 'chart.sales',
        title: 'Sales',
        placement: placement,
        enabled: true,
        config: {'metric': 'revenue'},
      );
      final dashboard = Dashboard(
        id: kMain,
        title: 'Main',
        owner: kOwner,
        tiles: [tile],
        isDefault: false,
      );

      final restoredPlacement = TilePlacement.fromJson(placement.toJson());
      expect(restoredPlacement, placement, reason: 'placement round-trips');
      expect(restoredPlacement.row, 2, reason: 'placement row preserved');
      expect(restoredPlacement.column, 3, reason: 'placement column preserved');
      expect(restoredPlacement.rowSpan, 1, reason: 'rowSpan preserved');
      expect(restoredPlacement.colSpan, 2, reason: 'colSpan preserved');

      final restoredTile = DashboardTile.fromJson(tile.toJson());
      expect(restoredTile.id, kTile, reason: 'tile id round-trips');
      expect(restoredTile.type, 'chart.sales', reason: 'tile type kept');
      expect(restoredTile.title, 'Sales', reason: 'tile title kept');
      expect(restoredTile.placement.row, 2, reason: 'nested placement intact');
      expect(restoredTile.placement.colSpan, 2, reason: 'nested colSpan kept');
      expect(restoredTile.enabled, isTrue, reason: 'enabled kept');
      expect(restoredTile.config['metric'], 'revenue', reason: 'config kept');

      final restoredDashboard = Dashboard.fromJson(dashboard.toJson());
      expect(restoredDashboard.id, kMain, reason: 'dashboard id round-trips');
      expect(restoredDashboard.title, 'Main', reason: 'dashboard title kept');
      expect(restoredDashboard.owner, kOwner, reason: 'dashboard owner kept');
      expect(restoredDashboard.isDefault, isFalse, reason: 'isDefault kept');
      expect(restoredDashboard.tiles, hasLength(1), reason: 'tiles kept');
      expect(restoredDashboard.tiles.first.id, kTile, reason: 'tile id kept');
      expect(
        restoredDashboard.tiles.first.placement.column,
        3,
        reason: 'nested tile placement kept',
      );
    });
  });
}
