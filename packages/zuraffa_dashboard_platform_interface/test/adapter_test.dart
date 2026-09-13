import 'package:flutter_test/flutter_test.dart';
import 'package:zuraffa_dashboard/zuraffa_dashboard.dart';
import 'package:zuraffa_dashboard_platform_interface/zuraffa_dashboard_platform_interface.dart';

const kMain = 'main';
const kTile = 'tile.sales';

Map<String, Object?> wireTile({String id = kTile}) => {
      'id': id,
      'type': 'chart.sales',
      'title': 'Sales',
      'placement': {'row': 0, 'column': 0, 'rowSpan': 1, 'colSpan': 2},
      'enabled': true,
      'config': <String, Object?>{'metric': 'revenue'},
    };

/// Feature `001-v6-dashboard-migration` — the adapter bridging the native
/// platform stack onto the core package's pure-Dart [DashboardPort]
/// (FR-006).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('method channel adapter (FR-006)', () {
    test('bridges wire layouts to typed tiles and back; unknown wire tiles degrade',
        () async {
      // An unknown-shape wire tile rides next to a well-formed one.
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(MethodChannelZuraffaDashboard.channel,
              (call) async {
        if (call.method == 'loadLayouts') {
          return {
            kMain: [
              wireTile(),
              {'completely': 'unknown'},
            ],
          };
        }
        return null;
      });
      addTearDown(() {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
                MethodChannelZuraffaDashboard.channel, null);
      });

      final adapter = MethodChannelDashboardAdapter(
        platform: MethodChannelZuraffaDashboard(),
      );

      // wire -> typed
      final layouts = await adapter.loadLayouts();
      final tiles = layouts[kMain] ?? <DashboardTile>[];
      expect(tiles, hasLength(1),
          reason: 'the unknown wire tile degrades away, the good one stays');
      expect(tiles.first.id, kTile,
          reason: 'the well-formed tile decodes typed');
      expect(tiles.first.placement.colSpan, 2,
          reason: 'the placement decodes');

      // typed -> wire
      var savedArgs = <Object?>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(MethodChannelZuraffaDashboard.channel,
              (call) async {
        if (call.method == 'saveLayout') {
          savedArgs = call.arguments as List<Object?>;
        }
        return null;
      });
      await adapter.saveLayout(kMain, tiles);
      expect(savedArgs.first, kMain, reason: 'the id leads the save');
      final savedTiles = savedArgs.last as List<Object?>;
      expect((savedTiles.first as Map)['id'], kTile,
          reason: 'typed tiles encode back to wire');
    });

    test('composed stack without a platform package answers every call safely',
        () async {
      // No federated registration: the adapter wraps the DEFAULT platform
      // instance; the composed core stack must answer everything.
      final adapter = MethodChannelDashboardAdapter();
      expect(await adapter.loadLayouts(), isEmpty,
          reason: 'nothing persisted before a platform registers');
      await adapter.saveLayout(kMain, const []);
      await adapter.removeLayout(kMain);
      await adapter.removeAll();
      expect(await adapter.loadLayouts(), isEmpty,
          reason: 'still empty, never a crash');
    });
  });
}
