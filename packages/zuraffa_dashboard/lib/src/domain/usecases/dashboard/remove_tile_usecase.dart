import 'package:zuraffa/zuraffa.dart';

import '../../entities/dashboard/dashboard.dart';
import '../../errors/dashboard_errors.dart';
import '../../repositories/dashboard_repository.dart';

/// Parameters for [RemoveTileUseCase].
class RemoveTileParams {
  const RemoveTileParams({required this.dashboardId, required this.tileId});

  final String dashboardId;
  final String tileId;
}

/// Tile management (FR-003): removes the tile identified by
/// [RemoveTileParams.tileId] from the board; an unknown tile raises the
/// typed [TileNotFoundException]. The mutated board persists.
class RemoveTileUseCase extends UseCase<Dashboard, RemoveTileParams> {
  RemoveTileUseCase(this._repository);

  final DashboardRepository _repository;

  @override
  Future<Dashboard> execute(
    RemoveTileParams params,
    CancelToken? cancelToken,
  ) async {
    cancelToken?.throwIfCancelled();
    final dashboard = await _repository.get(
      QueryParams<Dashboard>(params: {'id': params.dashboardId}),
    );
    if (!dashboard.tiles.any((t) => t.id == params.tileId)) {
      throw TileNotFoundException(params.dashboardId, params.tileId);
    }
    final updated = dashboard.copyWith(
      tiles: dashboard.tiles.where((t) => t.id != params.tileId).toList(),
    );
    return _repository.update(updated);
  }
}
