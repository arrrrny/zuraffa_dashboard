// dart format width=80
// ignore_for_file: UNNECESSARY_CAST
// ignore_for_file: type=lint

part of 'dashboard.dart';

// **************************************************************************
// ZorphyGenerator
// **************************************************************************

@JsonSerializable(explicitToJson: true, checked: true)
class Dashboard {
  Dashboard({
    required String this.id,
    required String this.title,
    required String this.owner,
    required List<DashboardTile> this.tiles,
    required bool this.isDefault,
  });

  factory Dashboard.fromJson(Map<String, dynamic> json) =>
      _$DashboardFromJson(json);

  final String id;

  final String title;

  final String owner;

  final List<DashboardTile> tiles;

  final bool isDefault;

  Dashboard copyWith({
    String? id,
    String? title,
    String? owner,
    List<DashboardTile>? tiles,
    bool? isDefault,
  }) {
    return Dashboard(
      id: id ?? this.id,
      title: title ?? this.title,
      owner: owner ?? this.owner,
      tiles: tiles ?? this.tiles,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  /// Returns a copy of this entity with [field] set to [value].
  ///
  /// Delegates to [copyWith]: the receiver is never mutated and a
  /// null [value] keeps the current field value.
  Dashboard copyWithField<T>(Field<Dashboard, T> field, T value) {
    switch (field.name) {
      case 'id':
        return copyWith(id: value as String);
      case 'title':
        return copyWith(title: value as String);
      case 'owner':
        return copyWith(owner: value as String);
      case 'tiles':
        return copyWith(tiles: value as List<DashboardTile>);
      case 'isDefault':
        return copyWith(isDefault: value as bool);
      default:
        throw ArgumentError.value(
          field.name,
          'field',
          'Dashboard has no settable field with this name',
        );
    }
  }

  Dashboard copyWithDashboard({
    String? id,
    String? title,
    String? owner,
    List<DashboardTile>? tiles,
    bool? isDefault,
  }) {
    return copyWith(
      id: id,
      title: title,
      owner: owner,
      tiles: tiles,
      isDefault: isDefault,
    );
  }

  Dashboard patchWithDashboard([DashboardPatch? patchInput]) {
    final _patcher = patchInput ?? DashboardPatch();
    final _patchMap = _patcher.patchMap;
    return Dashboard(
      id: _patchMap.containsKey(Dashboard$.id)
          ? ((_patchMap[Dashboard$.id] is Function)
                    ? _patchMap[Dashboard$.id](this.id)
                    : (_patchMap[Dashboard$.id] is Patch)
                    ? _patchMap[Dashboard$.id].applyTo(this.id)
                    : _patchMap[Dashboard$.id])
                as String
          : this.id,
      title: _patchMap.containsKey(Dashboard$.title)
          ? ((_patchMap[Dashboard$.title] is Function)
                    ? _patchMap[Dashboard$.title](this.title)
                    : (_patchMap[Dashboard$.title] is Patch)
                    ? _patchMap[Dashboard$.title].applyTo(this.title)
                    : _patchMap[Dashboard$.title])
                as String
          : this.title,
      owner: _patchMap.containsKey(Dashboard$.owner)
          ? ((_patchMap[Dashboard$.owner] is Function)
                    ? _patchMap[Dashboard$.owner](this.owner)
                    : (_patchMap[Dashboard$.owner] is Patch)
                    ? _patchMap[Dashboard$.owner].applyTo(this.owner)
                    : _patchMap[Dashboard$.owner])
                as String
          : this.owner,
      tiles: _patchMap.containsKey(Dashboard$.tiles)
          ? ((_patchMap[Dashboard$.tiles] is Function)
                    ? _patchMap[Dashboard$.tiles](this.tiles)
                    : (_patchMap[Dashboard$.tiles] is Patch)
                    ? _patchMap[Dashboard$.tiles].applyTo(this.tiles)
                    : _patchMap[Dashboard$.tiles])
                as List<DashboardTile>
          : this.tiles,
      isDefault: _patchMap.containsKey(Dashboard$.isDefault)
          ? ((_patchMap[Dashboard$.isDefault] is Function)
                    ? _patchMap[Dashboard$.isDefault](this.isDefault)
                    : (_patchMap[Dashboard$.isDefault] is Patch)
                    ? _patchMap[Dashboard$.isDefault].applyTo(this.isDefault)
                    : _patchMap[Dashboard$.isDefault])
                as bool
          : this.isDefault,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Dashboard &&
        id == other.id &&
        title == other.title &&
        owner == other.owner &&
        tiles == other.tiles &&
        isDefault == other.isDefault;
  }

  @override
  int get hashCode {
    return Object.hash(
      this.id,
      this.title,
      this.owner,
      this.tiles,
      this.isDefault,
    );
  }

  @override
  String toString() {
    return 'Dashboard(' +
        'id: ${id}' +
        ', ' +
        'title: ${title}' +
        ', ' +
        'owner: ${owner}' +
        ', ' +
        'tiles: ${tiles}' +
        ', ' +
        'isDefault: ${isDefault})';
  }

  Map<String, dynamic> toJsonLean() {
    final Map<String, dynamic> data = _$DashboardToJson(this);
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

extension DashboardPropertyHelpers on Dashboard {
  bool get hasId {
    return this.id.isNotEmpty;
  }

  bool get noId {
    return this.id.isEmpty;
  }

  bool get hasTitle {
    return this.title.isNotEmpty;
  }

  bool get noTitle {
    return this.title.isEmpty;
  }

  bool get hasOwner {
    return this.owner.isNotEmpty;
  }

  bool get noOwner {
    return this.owner.isEmpty;
  }

  bool get hasTiles {
    return this.tiles.isNotEmpty;
  }

  bool get noTiles {
    return this.tiles.isEmpty;
  }
}

extension DashboardSerialization on Dashboard {
  Map<String, dynamic> toJson() {
    return _$DashboardToJson(this);
  }
}

enum Dashboard$ { id, title, owner, tiles, isDefault }

class DashboardPatch extends PatchBase<Dashboard, Dashboard$> {
  Dashboard applyTo(Dashboard entity) {
    return entity.patchWithDashboard(this);
  }

  DashboardPatch withId(String? value) {
    patchMap[Dashboard$.id] = value;
    return this;
  }

  DashboardPatch withTitle(String? value) {
    patchMap[Dashboard$.title] = value;
    return this;
  }

  DashboardPatch withOwner(String? value) {
    patchMap[Dashboard$.owner] = value;
    return this;
  }

  DashboardPatch withTiles(List<DashboardTile>? value) {
    patchMap[Dashboard$.tiles] = value;
    return this;
  }

  DashboardPatch updateTilesAt(
    int index,
    DashboardTilePatch Function(DashboardTilePatch) patch,
  ) {
    patchMap[Dashboard$.tiles] = (List<dynamic> list) {
      var updatedList = List<DashboardTile>.from(list);
      if (index >= 0 && index < updatedList.length) {
        updatedList[index] = patch(
          DashboardTilePatch(),
        ).applyTo(updatedList[index] as DashboardTile);
      }
      return updatedList;
    };
    return this;
  }

  DashboardPatch withIsDefault(bool? value) {
    patchMap[Dashboard$.isDefault] = value;
    return this;
  }
}

/// Field descriptors for [Dashboard] query construction
abstract final class DashboardFields {
  static const id = Field<Dashboard, String>('id', _$id);

  static const title = Field<Dashboard, String>('title', _$title);

  static const owner = Field<Dashboard, String>('owner', _$owner);

  static const tiles = Field<Dashboard, List<DashboardTile>>('tiles', _$tiles);

  static const isDefault = Field<Dashboard, bool>('isDefault', _$isDefault);

  static String _$id(Dashboard e) {
    return e.id;
  }

  static String _$title(Dashboard e) {
    return e.title;
  }

  static String _$owner(Dashboard e) {
    return e.owner;
  }

  static List<DashboardTile> _$tiles(Dashboard e) {
    return e.tiles;
  }

  static bool _$isDefault(Dashboard e) {
    return e.isDefault;
  }
}

extension DashboardCompareE on Dashboard {
  Map<String, dynamic> compareToDashboard(Dashboard other) {
    final Map<String, dynamic> diff = {};

    if (id != other.id) {
      diff['id'] = () => other.id;
    }

    if (title != other.title) {
      diff['title'] = () => other.title;
    }

    if (owner != other.owner) {
      diff['owner'] = () => other.owner;
    }

    if (tiles != other.tiles) {
      diff['tiles'] = () => other.tiles;
    }

    if (isDefault != other.isDefault) {
      diff['isDefault'] = () => other.isDefault;
    }
    return diff;
  }
}
