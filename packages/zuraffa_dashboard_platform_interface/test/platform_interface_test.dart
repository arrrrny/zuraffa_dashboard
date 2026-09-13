import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zuraffa_dashboard/zuraffa_dashboard.dart';
import 'package:zuraffa_dashboard_platform_interface/zuraffa_dashboard_platform_interface.dart';

const kMain = 'main';
const kTile = 'tile.sales';

/// Feature `001-v6-dashboard-migration` — the native contract (FR-006):
/// the default instance safety, the MethodChannel protocol, and the port
/// bridge.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('default platform instance (FR-006)', () {
    test('loadLayouts on the default instance returns an empty map', () async {
      final platform = DefaultZuraffaDashboardPlatform();
      final layouts = await platform.loadLayouts();
      expect(layouts, isEmpty,
          reason: 'no platform package registered -> nothing persisted');
    });

    test('default instance writes complete without error (no-ops)', () async {
      final platform = DefaultZuraffaDashboardPlatform();
      await platform.saveLayout(kMain, const []);
      await platform.removeLayout(kMain);
      await platform.removeAll();
      expect(await platform.loadLayouts(), isEmpty,
          reason: 'writes stay no-ops on the default instance');
    });
  });

  group('method channel (FR-006)', () {
    test('loadLayouts decodes the wire map into per-id tile lists', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(MethodChannelZuraffaDashboard.channel,
              (call) async {
        expect(call.method, 'loadLayouts', reason: 'the documented method');
        return {
          kMain: [
            {
              'id': kTile,
              'type': 'chart.sales',
              'title': 'Sales',
              'placement': {'row': 0, 'column': 0, 'rowSpan': 1, 'colSpan': 2},
              'enabled': true,
              'config': {'metric': 'revenue'},
            },
          ],
        };
      });
      addTearDown(() {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
                MethodChannelZuraffaDashboard.channel, null);
      });

      final platform = MethodChannelZuraffaDashboard();
      final layouts = await platform.loadLayouts();
      expect(layouts[kMain], hasLength(1), reason: 'the layout is decoded');
      expect((layouts[kMain]!.first as Map)['id'], kTile,
          reason: 'the wire tile survives the trip');
    });

    test('saveLayout sends the documented method with [id, tiles] args',
        () async {
      var receivedMethod = '';
      var receivedArgs = <Object?>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(MethodChannelZuraffaDashboard.channel,
              (call) async {
        receivedMethod = call.method;
        receivedArgs = call.arguments as List<Object?>;
        return null;
      });
      addTearDown(() {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
                MethodChannelZuraffaDashboard.channel, null);
      });

      final platform = MethodChannelZuraffaDashboard();
      await platform.saveLayout(kMain, const [
        {
          'id': kTile,
          'type': 'chart.sales',
          'title': 'Sales',
          'placement': {'row': 0, 'column': 0, 'rowSpan': 1, 'colSpan': 1},
          'enabled': true,
          'config': <String, Object?>{},
        },
      ]);

      expect(receivedMethod, 'saveLayout', reason: 'the documented method');
      expect(receivedArgs, hasLength(2), reason: '[id, tiles] travel as a pair');
      expect(receivedArgs.first, kMain, reason: 'the dashboard id leads');
      final wireTiles = receivedArgs.last as List<Object?>;
      expect((wireTiles.first as Map)['id'], kTile,
          reason: 'the wire tiles are forwarded untouched');
    });
  });
}
