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
  /// Guarded construction (FR-001): [row]/[column] must be >= 0 and
  /// [rowSpan]/[colSpan] must be >= 1. The use cases enforce placement
  /// validity through this factory; the generated constructor stays plain.
  static TilePlacement create({
    required int row,
    required int column,
    required int rowSpan,
    required int colSpan,
  }) {
    if (row < 0) {
      throw ArgumentError.value(row, 'row', 'must be >= 0');
    }
    if (column < 0) {
      throw ArgumentError.value(column, 'column', 'must be >= 0');
    }
    if (rowSpan < 1) {
      throw ArgumentError.value(rowSpan, 'rowSpan', 'must be >= 1');
    }
    if (colSpan < 1) {
      throw ArgumentError.value(colSpan, 'colSpan', 'must be >= 1');
    }
    return TilePlacement(
      row: row,
      column: column,
      rowSpan: rowSpan,
      colSpan: colSpan,
    );
  }

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
