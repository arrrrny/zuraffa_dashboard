import 'package:zuraffa/zuraffa.dart';

import '../../entities/dashboard/dashboard.dart';
import '../../errors/dashboard_errors.dart';
import '../../repositories/dashboard_repository.dart';

/// Parameters for [CreateDashboardUseCase].
class CreateDashboardParams {
  const CreateDashboardParams({
    required this.id,
    required this.title,
    required this.owner,
  });

  final String id;
  final String title;
  final String owner;
}

/// Dashboard lifecycle (FR-003): creates a new, empty, non-default board
/// and persists it through the repository. Duplicate ids and empty
/// required fields fail typed.
class CreateDashboardUseCase extends UseCase<Dashboard, CreateDashboardParams> {
  CreateDashboardUseCase(this._repository);

  final DashboardRepository _repository;

  @override
  Future<Dashboard> execute(
    CreateDashboardParams params,
    CancelToken? cancelToken,
  ) async {
    cancelToken?.throwIfCancelled();
    if (params.id.isEmpty) {
      throw ArgumentError.value(params.id, 'id', 'must not be empty');
    }
    if (params.title.isEmpty) {
      throw ArgumentError.value(params.title, 'title', 'must not be empty');
    }
    if (params.owner.isEmpty) {
      throw ArgumentError.value(params.owner, 'owner', 'must not be empty');
    }

    try {
      await _repository.get(QueryParams<Dashboard>(params: {'id': params.id}));
      throw DuplicateDashboardException(params.id);
    } on DashboardNotFoundException {
      // expected: the id is free.
    }
    return _repository.create(Dashboard(
      id: params.id,
      title: params.title,
      owner: params.owner,
      tiles: const [],
      isDefault: false,
    ));
  }
}
