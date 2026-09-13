// dart format width=80
// ignore_for_file: UNNECESSARY_CAST
// ignore_for_file: type=lint

part of 'tile_placement.dart';

// **************************************************************************
// ZorphyGenerator
// **************************************************************************

@JsonSerializable(explicitToJson: true, checked: true)
class TilePlacement {
  TilePlacement({
    required int this.row,
    required int this.column,
    required int this.rowSpan,
    required int this.colSpan,
  });

  factory TilePlacement.create({
    required int row,
    required int column,
    required int rowSpan,
    required int colSpan,
  }) => $TilePlacement.create(
    row: row,
    column: column,
    rowSpan: rowSpan,
    colSpan: colSpan,
  );

  factory TilePlacement.fromJson(Map<String, dynamic> json) =>
      _$TilePlacementFromJson(json);

  final int row;

  final int column;

  final int rowSpan;

  final int colSpan;

  TilePlacement copyWith({int? row, int? column, int? rowSpan, int? colSpan}) {
    return TilePlacement(
      row: row ?? this.row,
      column: column ?? this.column,
      rowSpan: rowSpan ?? this.rowSpan,
      colSpan: colSpan ?? this.colSpan,
    );
  }

  /// Returns a copy of this entity with [field] set to [value].
  ///
  /// Delegates to [copyWith]: the receiver is never mutated and a
  /// null [value] keeps the current field value.
  TilePlacement copyWithField<T>(Field<TilePlacement, T> field, T value) {
    switch (field.name) {
      case 'row':
        return copyWith(row: value as int);
      case 'column':
        return copyWith(column: value as int);
      case 'rowSpan':
        return copyWith(rowSpan: value as int);
      case 'colSpan':
        return copyWith(colSpan: value as int);
      default:
        throw ArgumentError.value(
          field.name,
          'field',
          'TilePlacement has no settable field with this name',
        );
    }
  }

  TilePlacement copyWithTilePlacement({
    int? row,
    int? column,
    int? rowSpan,
    int? colSpan,
  }) {
    return copyWith(
      row: row,
      column: column,
      rowSpan: rowSpan,
      colSpan: colSpan,
    );
  }

  TilePlacement patchWithTilePlacement([TilePlacementPatch? patchInput]) {
    final _patcher = patchInput ?? TilePlacementPatch();
    final _patchMap = _patcher.patchMap;
    return TilePlacement(
      row: _patchMap.containsKey(TilePlacement$.row)
          ? ((_patchMap[TilePlacement$.row] is Function)
                    ? _patchMap[TilePlacement$.row](this.row)
                    : (_patchMap[TilePlacement$.row] is Patch)
                    ? _patchMap[TilePlacement$.row].applyTo(this.row)
                    : _patchMap[TilePlacement$.row])
                as int
          : this.row,
      column: _patchMap.containsKey(TilePlacement$.column)
          ? ((_patchMap[TilePlacement$.column] is Function)
                    ? _patchMap[TilePlacement$.column](this.column)
                    : (_patchMap[TilePlacement$.column] is Patch)
                    ? _patchMap[TilePlacement$.column].applyTo(this.column)
                    : _patchMap[TilePlacement$.column])
                as int
          : this.column,
      rowSpan: _patchMap.containsKey(TilePlacement$.rowSpan)
          ? ((_patchMap[TilePlacement$.rowSpan] is Function)
                    ? _patchMap[TilePlacement$.rowSpan](this.rowSpan)
                    : (_patchMap[TilePlacement$.rowSpan] is Patch)
                    ? _patchMap[TilePlacement$.rowSpan].applyTo(this.rowSpan)
                    : _patchMap[TilePlacement$.rowSpan])
                as int
          : this.rowSpan,
      colSpan: _patchMap.containsKey(TilePlacement$.colSpan)
          ? ((_patchMap[TilePlacement$.colSpan] is Function)
                    ? _patchMap[TilePlacement$.colSpan](this.colSpan)
                    : (_patchMap[TilePlacement$.colSpan] is Patch)
                    ? _patchMap[TilePlacement$.colSpan].applyTo(this.colSpan)
                    : _patchMap[TilePlacement$.colSpan])
                as int
          : this.colSpan,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TilePlacement &&
        row == other.row &&
        column == other.column &&
        rowSpan == other.rowSpan &&
        colSpan == other.colSpan;
  }

  @override
  int get hashCode {
    return Object.hash(this.row, this.column, this.rowSpan, this.colSpan);
  }

  @override
  String toString() {
    return 'TilePlacement(' +
        'row: ${row}' +
        ', ' +
        'column: ${column}' +
        ', ' +
        'rowSpan: ${rowSpan}' +
        ', ' +
        'colSpan: ${colSpan})';
  }

  Map<String, dynamic> toJsonLean() {
    final Map<String, dynamic> data = _$TilePlacementToJson(this);
    _sanitizeJson(data);
    return data;
  }

  dynamic _sanitizeJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      json.remove('__typename');
      return json..forEach((key, value) {
        json[key] = _sanitizeJson(value);
      });
    } else if (json is List) {
      return json.map((e) => _sanitizeJson(e)).toList();
    }
    return json;
  }
}

extension TilePlacementPropertyHelpers on TilePlacement {}

extension TilePlacementSerialization on TilePlacement {
  Map<String, dynamic> toJson() {
    return _$TilePlacementToJson(this);
  }
}

enum TilePlacement$ { row, column, rowSpan, colSpan }

class TilePlacementPatch extends PatchBase<TilePlacement, TilePlacement$> {
  TilePlacement applyTo(TilePlacement entity) {
    return entity.patchWithTilePlacement(this);
  }

  TilePlacementPatch withRow(int? value) {
    patchMap[TilePlacement$.row] = value;
    return this;
  }

  TilePlacementPatch withColumn(int? value) {
    patchMap[TilePlacement$.column] = value;
    return this;
  }

  TilePlacementPatch withRowSpan(int? value) {
    patchMap[TilePlacement$.rowSpan] = value;
    return this;
  }

  TilePlacementPatch withColSpan(int? value) {
    patchMap[TilePlacement$.colSpan] = value;
    return this;
  }
}

/// Field descriptors for [TilePlacement] query construction
abstract final class TilePlacementFields {
  static const row = Field<TilePlacement, int>('row', _$row);

  static const column = Field<TilePlacement, int>('column', _$column);

  static const rowSpan = Field<TilePlacement, int>('rowSpan', _$rowSpan);

  static const colSpan = Field<TilePlacement, int>('colSpan', _$colSpan);

  static int _$row(TilePlacement e) {
    return e.row;
  }

  static int _$column(TilePlacement e) {
    return e.column;
  }

  static int _$rowSpan(TilePlacement e) {
    return e.rowSpan;
  }

  static int _$colSpan(TilePlacement e) {
    return e.colSpan;
  }
}

extension TilePlacementCompareE on TilePlacement {
  Map<String, dynamic> compareToTilePlacement(TilePlacement other) {
    final Map<String, dynamic> diff = {};

    if (row != other.row) {
      diff['row'] = () => other.row;
    }

    if (column != other.column) {
      diff['column'] = () => other.column;
    }

    if (rowSpan != other.rowSpan) {
      diff['rowSpan'] = () => other.rowSpan;
    }

    if (colSpan != other.colSpan) {
      diff['colSpan'] = () => other.colSpan;
    }
    return diff;
  }
}
