import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'method_channel_zuraffa_dashboard.dart';

/// The native contract every zuraffa_dashboard platform package
/// implements: load/save/remove dashboard layouts keyed by dashboard id
/// (see contracts/method-channel-protocol.md).
///
/// The channel protocol (method → arguments → result):
/// - `loadLayouts` → none → `Map<Object?, Object?>` dashboardId → tile list.
/// - `saveLayout` → `[String dashboardId, List<Map> tiles]` → void.
/// - `removeLayout` → `[String dashboardId]` → void (no-op when absent).
/// - `removeAll` → none → void.
abstract class ZuraffaDashboardPlatform extends PlatformInterface {
  /// Constructs a platform interface.
  ZuraffaDashboardPlatform() : super(token: _token);

  static final Object _token = Object();

  static ZuraffaDashboardPlatform _instance =
      DefaultZuraffaDashboardPlatform();

  /// The default instance (overridden by platform packages at
  /// registration time via [instance = ...]).
  static ZuraffaDashboardPlatform get instance => _instance;

  /// Platform packages set this to their native implementation.
  static set instance(ZuraffaDashboardPlatform value) {
    PlatformInterface.verifyToken(value, _token);
    _instance = value;
  }

  /// Returns every persisted layout (dashboardId → tile list). An empty
  /// map means nothing persisted.
  Future<Map<String, List<Object?>>> loadLayouts() {
    throw UnimplementedError('loadLayouts() has not been implemented.');
  }

  /// Persists [tiles] as the layout of [dashboardId], overwriting any
  /// previous layout for that id atomically.
  Future<void> saveLayout(String dashboardId, List<Object?> tiles) {
    throw UnimplementedError('saveLayout() has not been implemented.');
  }

  /// Removes the layout of [dashboardId]; a no-op when absent.
  Future<void> removeLayout(String dashboardId) {
    throw UnimplementedError('removeLayout() has not been implemented.');
  }

  /// Removes every persisted layout.
  Future<void> removeAll() {
    throw UnimplementedError('removeAll() has not been implemented.');
  }
}

/// The fallback used when no platform package registered — answers every
/// call safely (empty layouts, no-op writes). This makes the interface
/// safe to depend on before a platform package loads (tests, pure-Dart
/// hosts), mirroring the sibling packages' defaults.
class DefaultZuraffaDashboardPlatform extends ZuraffaDashboardPlatform {
  @override
  Future<Map<String, List<Object?>>> loadLayouts() async =>
      const <String, List<Object?>>{};

  @override
  Future<void> saveLayout(String dashboardId, List<Object?> tiles) async {}

  @override
  Future<void> removeLayout(String dashboardId) async {}

  @override
  Future<void> removeAll() async {}
}

/// Wire shape helpers shared by the channel driver and the port bridge.
///
/// Layouts travel as JSON maps of the persisted dashboard:
/// `{dashboardId: [tile, …]}` with tiles serialized through their
/// generated `toJson` (fields: id, type, title, placement, enabled,
/// config). Unknown/extra fields forward untouched (forward compat).
abstract final class DashboardWire {
  static const channelName = 'zuraffa_dashboard';

  static Map<String, List<Object?>> decodeLayouts(Object? payload) {
    final raw = payload as Map<Object?, Object?>? ?? const {};
    return raw.map((key, value) => MapEntry(
          key! as String,
          (value as List<Object?>? ?? const []).toList(),
        ));
  }

  static List<Object?> encodeTiles(List<Object?> tiles) => tiles;
}

