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
  });
}
