import 'package:zorphy_annotation/zorphy_annotation.dart';

import '../dashboard_tile/dashboard_tile.dart';

part 'dashboard.zorphy.dart';

/// Dashboard entity (FR-001): a named, persisted dashboard layout owned by
/// a scope (e.g. user id). Holds ordered [DashboardTile]s; tile ids are
/// unique within the dashboard (enforced by the use cases, not the entity).
@Zorphy(generateCompareTo: true)
abstract class $Dashboard {
  /// Unique identifier, e.g. `main`.
  String get id;

  /// Human-readable display name.
  String get title;

  /// Scope owner (e.g. user id) the layout belongs to.
  String get owner;

  /// Ordered tiles on the board.
  List<DashboardTile> get tiles;

  /// Marks the built-in default layout template.
  bool get isDefault;
}
