import 'package:zorphy_annotation/zorphy_annotation.dart';

import '../tile_placement/tile_placement.dart';

part 'dashboard_tile.zorphy.dart';

/// DashboardTile entity (FR-001): one card on a dashboard, identified by a
/// unique [id] within its dashboard, discriminated by [type], placed on the
/// grid via [placement], and carrying an opaque JSON-encodable [config].
@Zorphy(generateCompareTo: true)
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
