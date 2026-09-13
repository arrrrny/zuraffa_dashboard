// dart format width=80
// ignore_for_file: UNNECESSARY_CAST
// ignore_for_file: type=lint

part of 'dashboard_tile.dart';

// **************************************************************************
// ZorphyGenerator
// **************************************************************************

class DashboardTile {
  DashboardTile({
    required String this.id,
    required String this.type,
    required String this.title,
    required TilePlacement this.placement,
    required bool this.enabled,
    required Map<String, Object?> this.config,
  });

  final String id;

  final String type;

  final String title;

  final TilePlacement placement;

  final bool enabled;

  final Map<String, Object?> config;

  DashboardTile copyWith({
    String? id,
    String? type,
    String? title,
    TilePlacement? placement,
    bool? enabled,
    Map<String, Object?>? config,
  }) {
    return DashboardTile(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      placement: placement ?? this.placement,
      enabled: enabled ?? this.enabled,
      config: config ?? this.config,
    );
  }

  /// Returns a copy of this entity with [field] set to [value].
  ///
  /// Delegates to [copyWith]: the receiver is never mutated and a
  /// null [value] keeps the current field value.
  DashboardTile copyWithField<T>(Field<DashboardTile, T> field, T value) {
    switch (field.name) {
      case 'id':
        return copyWith(id: value as String);
      case 'type':
        return copyWith(type: value as String);
      case 'title':
        return copyWith(title: value as String);
      case 'placement':
        return copyWith(placement: value as TilePlacement);
      case 'enabled':
        return copyWith(enabled: value as bool);
      case 'config':
        return copyWith(config: value as Map<String, Object?>);
      default:
        throw ArgumentError.value(
          field.name,
          'field',
          'DashboardTile has no settable field with this name',
        );
    }
  }

  DashboardTile copyWithDashboardTile({
    String? id,
    String? type,
    String? title,
    TilePlacement? placement,
    bool? enabled,
    Map<String, Object?>? config,
  }) {
    return copyWith(
      id: id,
      type: type,
      title: title,
      placement: placement,
      enabled: enabled,
      config: config,
    );
  }

  DashboardTile patchWithDashboardTile([DashboardTilePatch? patchInput]) {
    final _patcher = patchInput ?? DashboardTilePatch();
    final _patchMap = _patcher.patchMap;
    return DashboardTile(
      id: _patchMap.containsKey(DashboardTile$.id)
          ? ((_patchMap[DashboardTile$.id] is Function)
                    ? _patchMap[DashboardTile$.id](this.id)
                    : (_patchMap[DashboardTile$.id] is Patch)
                    ? _patchMap[DashboardTile$.id].applyTo(this.id)
                    : _patchMap[DashboardTile$.id])
                as String
          : this.id,
      type: _patchMap.containsKey(DashboardTile$.type)
          ? ((_patchMap[DashboardTile$.type] is Function)
                    ? _patchMap[DashboardTile$.type](this.type)
                    : (_patchMap[DashboardTile$.type] is Patch)
                    ? _patchMap[DashboardTile$.type].applyTo(this.type)
                    : _patchMap[DashboardTile$.type])
                as String
          : this.type,
      title: _patchMap.containsKey(DashboardTile$.title)
          ? ((_patchMap[DashboardTile$.title] is Function)
                    ? _patchMap[DashboardTile$.title](this.title)
                    : (_patchMap[DashboardTile$.title] is Patch)
                    ? _patchMap[DashboardTile$.title].applyTo(this.title)
                    : _patchMap[DashboardTile$.title])
                as String
          : this.title,
      placement: _patchMap.containsKey(DashboardTile$.placement)
          ? ((_patchMap[DashboardTile$.placement] is Function)
                    ? _patchMap[DashboardTile$.placement](this.placement)
                    : (_patchMap[DashboardTile$.placement] is Patch)
                    ? _patchMap[DashboardTile$.placement].applyTo(
                        this.placement,
                      )
                    : _patchMap[DashboardTile$.placement])
                as TilePlacement
          : this.placement,
      enabled: _patchMap.containsKey(DashboardTile$.enabled)
          ? ((_patchMap[DashboardTile$.enabled] is Function)
                    ? _patchMap[DashboardTile$.enabled](this.enabled)
                    : (_patchMap[DashboardTile$.enabled] is Patch)
                    ? _patchMap[DashboardTile$.enabled].applyTo(this.enabled)
                    : _patchMap[DashboardTile$.enabled])
                as bool
          : this.enabled,
      config: _patchMap.containsKey(DashboardTile$.config)
          ? ((_patchMap[DashboardTile$.config] is Function)
                    ? _patchMap[DashboardTile$.config](this.config)
                    : (_patchMap[DashboardTile$.config] is Patch)
                    ? _patchMap[DashboardTile$.config].applyTo(this.config)
                    : _patchMap[DashboardTile$.config])
                as Map<String, Object?>
          : this.config,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DashboardTile &&
        id == other.id &&
        type == other.type &&
        title == other.title &&
        placement == other.placement &&
        enabled == other.enabled &&
        config == other.config;
  }

  @override
  int get hashCode {
    return Object.hash(
      this.id,
      this.type,
      this.title,
      this.placement,
      this.enabled,
      this.config,
    );
  }

  @override
  String toString() {
    return 'DashboardTile(' +
        'id: ${id}' +
        ', ' +
        'type: ${type}' +
        ', ' +
        'title: ${title}' +
        ', ' +
        'placement: ${placement}' +
        ', ' +
        'enabled: ${enabled}' +
        ', ' +
        'config: ${config})';
  }
}

extension DashboardTilePropertyHelpers on DashboardTile {
  bool get hasId {
    return this.id.isNotEmpty;
  }

  bool get noId {
    return this.id.isEmpty;
  }

  bool get hasType {
    return this.type.isNotEmpty;
  }

  bool get noType {
    return this.type.isEmpty;
  }

  bool get hasTitle {
    return this.title.isNotEmpty;
  }

  bool get noTitle {
    return this.title.isEmpty;
  }

  bool get hasConfig {
    return this.config.isNotEmpty;
  }

  bool get noConfig {
    return this.config.isEmpty;
  }
}

enum DashboardTile$ { id, type, title, placement, enabled, config }

class DashboardTilePatch extends PatchBase<DashboardTile, DashboardTile$> {
  DashboardTile applyTo(DashboardTile entity) {
    return entity.patchWithDashboardTile(this);
  }

  DashboardTilePatch withId(String? value) {
    patchMap[DashboardTile$.id] = value;
    return this;
  }

  DashboardTilePatch withType(String? value) {
    patchMap[DashboardTile$.type] = value;
    return this;
  }

  DashboardTilePatch withTitle(String? value) {
    patchMap[DashboardTile$.title] = value;
    return this;
  }

  DashboardTilePatch withPlacement(TilePlacement? value) {
    patchMap[DashboardTile$.placement] = value;
    return this;
  }

  DashboardTilePatch withEnabled(bool? value) {
    patchMap[DashboardTile$.enabled] = value;
    return this;
  }

  DashboardTilePatch withConfig(Map<String, Object?>? value) {
    patchMap[DashboardTile$.config] = value;
    return this;
  }
}

/// Field descriptors for [DashboardTile] query construction
abstract final class DashboardTileFields {
  static const id = Field<DashboardTile, String>('id', _$id);

  static const type = Field<DashboardTile, String>('type', _$type);

  static const title = Field<DashboardTile, String>('title', _$title);

  static const placement = Field<DashboardTile, TilePlacement>(
    'placement',
    _$placement,
  );

  static const enabled = Field<DashboardTile, bool>('enabled', _$enabled);

  static const config = Field<DashboardTile, Map<String, Object?>>(
    'config',
    _$config,
  );

  static String _$id(DashboardTile e) {
    return e.id;
  }

  static String _$type(DashboardTile e) {
    return e.type;
  }

  static String _$title(DashboardTile e) {
    return e.title;
  }

  static TilePlacement _$placement(DashboardTile e) {
    return e.placement;
  }

  static bool _$enabled(DashboardTile e) {
    return e.enabled;
  }

  static Map<String, Object?> _$config(DashboardTile e) {
    return e.config;
  }
}

extension DashboardTileCompareE on DashboardTile {
  Map<String, dynamic> compareToDashboardTile(DashboardTile other) {
    final Map<String, dynamic> diff = {};

    if (id != other.id) {
      diff['id'] = () => other.id;
    }

    if (type != other.type) {
      diff['type'] = () => other.type;
    }

    if (title != other.title) {
      diff['title'] = () => other.title;
    }

    if (placement != other.placement) {
      diff['placement'] = () => other.placement;
    }

    if (enabled != other.enabled) {
      diff['enabled'] = () => other.enabled;
    }

    if (config != other.config) {
      diff['config'] = () => other.config;
    }
    return diff;
  }
}
