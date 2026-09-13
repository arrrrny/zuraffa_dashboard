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
  });
}
