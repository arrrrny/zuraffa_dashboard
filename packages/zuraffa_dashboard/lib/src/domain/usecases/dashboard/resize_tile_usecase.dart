import 'package:zuraffa/zuraffa.dart';

import '../../entities/dashboard/dashboard.dart';
import '../../entities/tile_placement/tile_placement.dart';
import '../../errors/dashboard_errors.dart';
import '../../repositories/dashboard_repository.dart';

/// Parameters for [ResizeTileUseCase].
class ResizeTileParams {
  const ResizeTileParams({
    required this.dashboardId,
    required this.tileId,
    required this.rowSpan,
    required this.colSpan,
  });

  final String dashboardId;
  final String tileId;
  final int rowSpan;
  final int colSpan;
}

/// Tile management (FR-003): resizes the tile through the guarded
/// `TilePlacement.create` (spans >= 1, position unchanged); an unknown
/// tile raises the typed [TileNotFoundException]. Persists through the
/// repository.
class ResizeTileUseCase extends UseCase<Dashboard, ResizeTileParams> {
  ResizeTileUseCase(this._repository);

  final DashboardRepository _repository;

  @override
  Future<Dashboard> execute(
    ResizeTileParams params,
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
      row: target.first.placement.row,
      column: target.first.placement.column,
      rowSpan: params.rowSpan,
      colSpan: params.colSpan,
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
