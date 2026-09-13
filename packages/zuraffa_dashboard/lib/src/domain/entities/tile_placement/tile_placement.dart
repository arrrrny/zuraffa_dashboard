/// TilePlacement value object (FR-001): grid position + span of one tile.
/// Becomes a full Zorphy value object in its own behavior cycle (U3);
/// declared here so the [DashboardTile] signature resolves.
abstract class $TilePlacement {
  int get row;
  int get column;
  int get rowSpan;
  int get colSpan;
}

class TilePlacement implements $TilePlacement {
  TilePlacement({
    required this.row,
    required this.column,
    required this.rowSpan,
    required this.colSpan,
  });

  @override
  final int row;
  @override
  final int column;
  @override
  final int rowSpan;
  @override
  final int colSpan;
}
