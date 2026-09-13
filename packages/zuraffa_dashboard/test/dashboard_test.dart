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
  });
}
