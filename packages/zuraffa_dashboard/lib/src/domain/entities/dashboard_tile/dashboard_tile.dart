import '../tile_placement/tile_placement.dart';

/// DashboardTile entity (FR-001): one card on a dashboard. Becomes a full
/// Zorphy entity in its own behavior cycle (U2); declared here so the
/// [Dashboard] signature resolves.
abstract class $DashboardTile {
  /// Unique identifier within its dashboard.
  String get id;

  /// Tile-kind discriminator, e.g. `chart.sales`.
  String get type;

  /// Human-readable display name.
  String get title;

  /// Grid position + span.
  TilePlacement get placement;

  /// Disabled tiles render as placeholders.
  bool get enabled;

  /// Opaque JSON-encodable payload.
  Map<String, Object?> get config;
}

class DashboardTile implements $DashboardTile {
  DashboardTile({
    required this.id,
    required this.type,
    required this.title,
    required this.placement,
    required this.enabled,
    required this.config,
  });

  @override
  final String id;
  @override
  final String type;
  @override
  final String title;
  @override
  final TilePlacement placement;
  @override
  final bool enabled;
  @override
  final Map<String, Object?> config;
}
