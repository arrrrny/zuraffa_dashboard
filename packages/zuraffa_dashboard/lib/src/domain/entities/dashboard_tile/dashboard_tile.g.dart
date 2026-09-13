// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_tile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DashboardTile _$DashboardTileFromJson(Map<String, dynamic> json) =>
    $checkedCreate('DashboardTile', json, ($checkedConvert) {
      final val = DashboardTile(
        id: $checkedConvert('id', (v) => v as String),
        type: $checkedConvert('type', (v) => v as String),
        title: $checkedConvert('title', (v) => v as String),
        placement: $checkedConvert(
          'placement',
          (v) => TilePlacement.fromJson(v as Map<String, dynamic>),
        ),
        enabled: $checkedConvert('enabled', (v) => v as bool),
        config: $checkedConvert('config', (v) => v as Map<String, dynamic>),
      );
      return val;
    });

Map<String, dynamic> _$DashboardTileToJson(DashboardTile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'title': instance.title,
      'placement': instance.placement.toJson(),
      'enabled': instance.enabled,
      'config': instance.config,
    };
