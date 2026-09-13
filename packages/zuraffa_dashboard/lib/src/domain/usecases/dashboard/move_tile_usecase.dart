import 'package:zuraffa/zuraffa.dart';

import '../../entities/dashboard/dashboard.dart';
import '../../entities/tile_placement/tile_placement.dart';
import '../../errors/dashboard_errors.dart';
import '../../repositories/dashboard_repository.dart';

/// Parameters for [MoveTileUseCase].
class MoveTileParams {
  const MoveTileParams({
    required this.dashboardId,
    required this.tileId,
    required this.row,
    required this.column,
  });

  final String dashboardId;
  final String tileId;
  final int row;
  final int column;
}

/// Tile management (FR-003): moves the tile to the guarded placement
/// (row/column via [TilePlacement.create], spans unchanged); an unknown
/// tile raises the typed [TileNotFoundException]. Persists through the
/// repository.
class MoveTileUseCase extends UseCase<Dashboard, MoveTileParams> {
  MoveTileUseCase(this._repository);

  final DashboardRepository _repository;

  @override
  Future<Dashboard> execute(
    MoveTileParams params,
    CancelToken? cancelToken,
  ) async {
    cancelToken?.throwIfCancelled();
    final dashboard = await _repository.get(
      QueryParams<Dashboard>(params: {'id': params.dashboardId}),
    );
    final target = dashboard.tiles.where((t) => t.id == params.tileId).toList();
    if (target.isEmpty) {
      throw TileNotFoundException(params.dashboardId, params.tileId);
    }
    final placement = TilePlacement.create(
      row: params.row,
      column: params.column,
      rowSpan: target.first.placement.rowSpan,
      colSpan: target.first.placement.colSpan,
    );
    final updated = dashboard.copyWith(
      tiles: [
        for (final t in dashboard.tiles)
          if (t.id == params.tileId) t.copyWith(placement: placement) else t,
      ],
    );
    return _repository.update(updated);
  }
}
