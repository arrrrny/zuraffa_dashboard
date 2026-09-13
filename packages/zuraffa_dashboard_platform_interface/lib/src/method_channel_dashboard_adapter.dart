import 'package:zuraffa_dashboard/zuraffa_dashboard.dart';

import 'dashboard_platform_interface.dart';

/// Bridges the [ZuraffaDashboardPlatform] native implementation onto the
/// core package's pure-Dart [DashboardPort], so apps register the real
/// platform stack with the same DI seam as the in-memory tests:
///
/// ```dart
/// registerDashboardDependencies(
///   getIt,
///   port: MethodChannelDashboardAdapter(),
/// );
/// ```
///
/// Unknown wire tiles degrade away (skipped) instead of crashing the host
/// — forward-compatible against a newer native SDK writing richer shapes.
class MethodChannelDashboardAdapter implements DashboardPort {
  /// The platform instance backing this adapter (defaults to
  /// [ZuraffaDashboardPlatform.instance]).
  final ZuraffaDashboardPlatform platform;

  MethodChannelDashboardAdapter({ZuraffaDashboardPlatform? platform})
    : platform = platform ?? ZuraffaDashboardPlatform.instance;

  @override
  Future<Map<String, List<DashboardTile>>> loadLayouts() async {
    final wire = await platform.loadLayouts();
    return wire.map((id, tiles) => MapEntry(id, _decodeTiles(tiles)));
  }

  @override
  Future<void> saveLayout(String dashboardId, List<DashboardTile> tiles) {
    return platform.saveLayout(
      dashboardId,
      tiles.map((tile) => tile.toJson()).toList(),
    );
  }

  @override
  Future<void> removeLayout(String dashboardId) =>
      platform.removeLayout(dashboardId);

  @override
  Future<void> removeAll() => platform.removeAll();

  /// Decodes wire tile maps; entries that fail to decode are skipped.
  static List<DashboardTile> _decodeTiles(List<Object?> tiles) {
    final decoded = <DashboardTile>[];
    for (final tile in tiles) {
      if (tile is! Map) continue;
      try {
        decoded.add(DashboardTile.fromJson(_deepStringKeys(tile)));
      } on Object {
        // Unknown shape from a newer native SDK — degrade, never crash.
      }
    }
    return decoded;
  }

  /// The platform codec decodes maps with `Object?` keys while the
  /// generated `fromJson` casts to `Map<String, dynamic>` — convert
  /// recursively before decoding.
  static Map<String, Object?> _deepStringKeys(Map<Object?, Object?> map) =>
      {
        for (final entry in map.entries)
          entry.key! as String: _deepValue(entry.value),
      };

  static Object? _deepValue(Object? value) {
    if (value is Map<Object?, Object?>) return _deepStringKeys(value);
    if (value is List<Object?>) return [for (final v in value) _deepValue(v)];
    return value;
  }
}
