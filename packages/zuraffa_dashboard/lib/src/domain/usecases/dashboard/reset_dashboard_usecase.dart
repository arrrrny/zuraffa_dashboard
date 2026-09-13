import 'package:zuraffa/zuraffa.dart';

import '../../dashboard_port.dart';
import '../../entities/dashboard/dashboard.dart';
import '../../repositories/dashboard_repository.dart';

/// Parameters for [ResetDashboardUseCase].
class ResetDashboardParams {
  const ResetDashboardParams({required this.dashboardId});

  final String dashboardId;
}

/// Dashboard lifecycle (FR-003): restores the board's tiles from the
/// owner's default template (the board flagged `isDefault`). Without a
/// template the board resets to empty. The port layout mirrors the reset.
class ResetDashboardUseCase extends UseCase<Dashboard, ResetDashboardParams> {
  ResetDashboardUseCase(this._repository, this._port);

  final DashboardRepository _repository;
  final DashboardPort _port;

  @override
  Future<Dashboard> execute(
    ResetDashboardParams params,
    CancelToken? cancelToken,
  ) async {
    cancelToken?.throwIfCancelled();
    final dashboard = await _repository.get(
      QueryParams<Dashboard>(params: {'id': params.dashboardId}),
    );
    final ownerBoards = await _repository.getList(
      ListQueryParams<Dashboard>(params: {'owner': dashboard.owner}),
    );
    final templates = ownerBoards.where((b) => b.isDefault).toList();
    final restored = dashboard.copyWith(
      tiles: templates.isEmpty
          ? const []
          : List.of(templates.first.tiles),
    );
    final updated = await _repository.update(restored);
    await _port.saveLayout(updated.id, updated.tiles);
    return updated;
  }
}
