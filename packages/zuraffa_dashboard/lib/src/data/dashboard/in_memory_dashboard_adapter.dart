import '../../domain/dashboard_port.dart';
import '../../domain/entities/dashboard_tile/dashboard_tile.dart';

/// The pure-Dart default [DashboardPort] (FR-005): an in-memory state
/// machine so the package runs and tests without any platform. Federated
/// platform packages replace it at `registerWith()` time via
/// `setPlatformDashboardPortFactory`.
class InMemoryDashboardAdapter implements DashboardPort {
  final Map<String, List<DashboardTile>> _layouts = {};

  @override
  Future<Map<String, List<DashboardTile>>> loadLayouts() async {
    return {
      for (final entry in _layouts.entries)
        entry.key: List<DashboardTile>.unmodifiable(entry.value),
    };
  }

  @override
  Future<void> saveLayout(String dashboardId, List<DashboardTile> tiles) async {
    _layouts[dashboardId] = List<DashboardTile>.unmodifiable(tiles);
  }

  @override
  Future<void> removeLayout(String dashboardId) async {
    _layouts.remove(dashboardId);
  }

  @override
  Future<void> removeAll() async {
    _layouts.clear();
  }
}
