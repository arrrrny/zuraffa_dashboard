import 'package:zuraffa/zuraffa.dart';

import '../entities/dashboard/dashboard.dart';

/// Dashboard repository contract (FR-002) — the domain's view of
/// dashboard persistence, mirroring the sibling generated repositories.
abstract class DashboardRepository {
  Future<Dashboard> get(QueryParams<Dashboard> params);
  Future<List<Dashboard>> getList(ListQueryParams<Dashboard> params);
  Future<Dashboard> create(Dashboard dashboard);
}
