// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Dashboard _$DashboardFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Dashboard', json, ($checkedConvert) {
      final val = Dashboard(
        id: $checkedConvert('id', (v) => v as String),
        title: $checkedConvert('title', (v) => v as String),
        owner: $checkedConvert('owner', (v) => v as String),
        tiles: $checkedConvert(
          'tiles',
          (v) => (v as List<dynamic>)
              .map((e) => DashboardTile.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        isDefault: $checkedConvert('isDefault', (v) => v as bool),
      );
      return val;
    });

Map<String, dynamic> _$DashboardToJson(Dashboard instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'owner': instance.owner,
  'tiles': instance.tiles.map((e) => e.toJson()).toList(),
  'isDefault': instance.isDefault,
};
