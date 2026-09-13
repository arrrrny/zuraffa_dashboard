import 'package:zuraffa/zuraffa.dart';

import '../../entities/dashboard/dashboard.dart';
import '../../repositories/dashboard_repository.dart';

/// Parameters for [GetDashboardUseCase].
class GetDashboardParams {
  const GetDashboardParams({required this.id});

  final String id;
}

/// Dashboard query (FR-003): returns the stored board for
/// [GetDashboardParams.id]; an unknown id raises the typed
/// [DashboardNotFoundException].
class GetDashboardUseCase extends UseCase<Dashboard, GetDashboardParams> {
  GetDashboardUseCase(this._repository);

  final DashboardRepository _repository;

  @override
  Future<Dashboard> execute(
    GetDashboardParams params,
    CancelToken? cancelToken,
  ) async {
    cancelToken?.throwIfCancelled();
    return _repository.get(
      QueryParams<Dashboard>(params: {'id': params.id}),
    );
  }
}
