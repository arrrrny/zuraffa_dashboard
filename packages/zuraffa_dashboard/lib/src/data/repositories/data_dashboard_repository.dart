import 'package:zuraffa/zuraffa.dart';

import '../../domain/entities/dashboard/dashboard.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard/dashboard_datasource.dart';

/// Data-layer [DashboardRepository] (FR-002): delegates to the
/// [DashboardDataSource]; swap datasources without touching the domain.
class DataDashboardRepository implements DashboardRepository {
  DataDashboardRepository(this._dataSource);

  final DashboardDataSource _dataSource;

  @override
  Future<Dashboard> get(QueryParams<Dashboard> params) =>
      _dataSource.get(params);

  @override
  Future<List<Dashboard>> getList(ListQueryParams<Dashboard> params) =>
      _dataSource.getList(params);

  @override
  Future<Dashboard> create(Dashboard dashboard) => _dataSource.create(dashboard);
}
