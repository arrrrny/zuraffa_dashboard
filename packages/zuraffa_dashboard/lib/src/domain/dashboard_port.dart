import 'entities/dashboard_tile/dashboard_tile.dart';

/// The technology-agnostic dashboard contract (FR-005).
///
/// Consumers program against this port; platform adapters
/// (zuraffa_dashboard_android/ios/…) implement it. The default
/// [InMemoryDashboardAdapter] is a pure-Dart state machine so the whole
/// package — and every app's dashboard logic — tests without a platform.
abstract class DashboardPort {
  /// Loads every persisted layout keyed by dashboard id. Absent ids are
  /// simply missing from the map; an empty map means nothing persisted.
  Future<Map<String, List<DashboardTile>>> loadLayouts();

  /// Persists [tiles] as the layout of [dashboardId], overwriting any
  /// previous layout for that id atomically.
  Future<void> saveLayout(String dashboardId, List<DashboardTile> tiles);

  /// Removes the layout of [dashboardId]; a no-op when absent.
  Future<void> removeLayout(String dashboardId);

  /// Removes every persisted layout.
  Future<void> removeAll();
}
