import 'package:flutter/services.dart';

import 'dashboard_platform_interface.dart';

/// The MethodChannel client half: what the native Kotlin/Swift plugins
/// implement. Platform packages typically re-export this as their
/// registration target so the channel name and protocol stay identical
/// across platforms (see contracts/method-channel-protocol.md).
class MethodChannelZuraffaDashboard extends ZuraffaDashboardPlatform {
  /// The shared channel — every platform package registers the same
  /// name (`zuraffa_dashboard`).
  static const MethodChannel channel = MethodChannel('zuraffa_dashboard');

  @override
  Future<Map<String, List<Object?>>> loadLayouts() async {
    final raw = await channel.invokeMethod<Map<Object?, Object?>>(
      'loadLayouts',
    );
    return DashboardWire.decodeLayouts(raw);
  }

  @override
  Future<void> saveLayout(String dashboardId, List<Object?> tiles) async {
    await channel.invokeMethod<void>(
      'saveLayout',
      [dashboardId, DashboardWire.encodeTiles(tiles)],
    );
  }

  @override
  Future<void> removeLayout(String dashboardId) async {
    await channel.invokeMethod<void>('removeLayout', [dashboardId]);
  }

  @override
  Future<void> removeAll() async {
    await channel.invokeMethod<void>('removeAll');
  }
}
