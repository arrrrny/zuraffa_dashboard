import 'package:zuraffa/zuraffa.dart';

import '../../dashboard_port.dart';
import '../../entities/dashboard/dashboard.dart';
import '../../repositories/dashboard_repository.dart';

/// Parameters for [SaveDashboardUseCase].
class SaveDashboardParams {
  const SaveDashboardParams({required this.dashboard});

  final Dashboard dashboard;
}

/// Dashboard lifecycle (FR-003): persists [SaveDashboardParams.dashboard]
/// through BOTH persistence faces — the repository (domain state) and the
/// port (the layout snapshot platform adapters mirror).
class SaveDashboardUseCase extends UseCase<void, SaveDashboardParams> {
  SaveDashboardUseCase(this._repository, this._port);

  final DashboardRepository _repository;
  final DashboardPort _port;

  @override
  Future<void> execute(
    SaveDashboardParams params,
    CancelToken? cancelToken,
  ) async {
    cancelToken?.throwIfCancelled();
    await _repository.update(params.dashboard);
    await _port.saveLayout(params.dashboard.id, params.dashboard.tiles);
  }
}
