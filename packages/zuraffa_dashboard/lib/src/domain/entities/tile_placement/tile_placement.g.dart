// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tile_placement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TilePlacement _$TilePlacementFromJson(Map<String, dynamic> json) =>
    $checkedCreate('TilePlacement', json, ($checkedConvert) {
      final val = TilePlacement(
        row: $checkedConvert('row', (v) => (v as num).toInt()),
        column: $checkedConvert('column', (v) => (v as num).toInt()),
        rowSpan: $checkedConvert('rowSpan', (v) => (v as num).toInt()),
        colSpan: $checkedConvert('colSpan', (v) => (v as num).toInt()),
      );
      return val;
    });

Map<String, dynamic> _$TilePlacementToJson(TilePlacement instance) =>
    <String, dynamic>{
      'row': instance.row,
      'column': instance.column,
      'rowSpan': instance.rowSpan,
      'colSpan': instance.colSpan,
    };
