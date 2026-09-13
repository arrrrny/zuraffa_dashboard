import 'package:zuraffa/zuraffa.dart';

import '../../entities/dashboard/dashboard.dart';
import '../../entities/dashboard_tile/dashboard_tile.dart';
import '../../errors/dashboard_errors.dart';
import '../../repositories/dashboard_repository.dart';

/// Parameters for [AddTileUseCase].
class AddTileParams {
  const AddTileParams({required this.dashboardId, required this.tile});

  final String dashboardId;
  final DashboardTile tile;
}

/// Tile management (FR-003): appends [AddTileParams.tile] to the board,
/// rejecting duplicate tile ids. The mutated board persists through the
/// repository.
class AddTileUseCase extends UseCase<Dashboard, AddTileParams> {
  AddTileUseCase(this._repository);

  final DashboardRepository _repository;

  @override
  Future<Dashboard> execute(
    AddTileParams params,
    CancelToken? cancelToken,
  ) async {
    cancelToken?.throwIfCancelled();
    final dashboard = await _repository.get(
      QueryParams<Dashboard>(params: {'id': params.dashboardId}),
    );
    final exists = dashboard.tiles.any((t) => t.id == params.tile.id);
    if (exists) {
      throw DuplicateTileException(params.dashboardId, params.tile.id);
    }
    final updated = dashboard.copyWith(
      tiles: [...dashboard.tiles, params.tile],
    );
    return _repository.update(updated);
  }
}
