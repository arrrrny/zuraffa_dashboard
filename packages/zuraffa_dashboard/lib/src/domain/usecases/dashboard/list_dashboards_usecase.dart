import 'package:zuraffa/zuraffa.dart';

import '../../entities/dashboard/dashboard.dart';
import '../../repositories/dashboard_repository.dart';

/// Parameters for [ListDashboardsUseCase].
class ListDashboardsParams {
  const ListDashboardsParams({required this.owner});

  final String owner;
}

/// Dashboard query (FR-003): lists the dashboards owned by [ListDashboardsParams.owner].
/// An unknown owner yields an empty list.
class ListDashboardsUseCase
    extends UseCase<List<Dashboard>, ListDashboardsParams> {
  ListDashboardsUseCase(this._repository);

  final DashboardRepository _repository;

  @override
  Future<List<Dashboard>> execute(
    ListDashboardsParams params,
    CancelToken? cancelToken,
  ) async {
    cancelToken?.throwIfCancelled();
    return _repository.getList(
      ListQueryParams<Dashboard>(params: {'owner': params.owner}),
    );
  }
}
