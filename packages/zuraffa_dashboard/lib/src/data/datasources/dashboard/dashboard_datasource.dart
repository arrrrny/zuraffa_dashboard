import 'package:zuraffa/zuraffa.dart';

import '../../../domain/entities/dashboard/dashboard.dart';

/// The dashboard datasource contract (FR-002), mirroring the sibling
/// generated datasources: get one, list many, create.
abstract class DashboardDataSource
    with Loggable, FailureHandler {
  Future<Dashboard> get(QueryParams<Dashboard> params);
  Future<List<Dashboard>> getList(ListQueryParams<Dashboard> params);
  Future<Dashboard> create(Dashboard dashboard);
}
