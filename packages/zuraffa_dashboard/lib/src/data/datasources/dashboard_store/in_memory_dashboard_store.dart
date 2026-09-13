import 'package:zuraffa/zuraffa.dart';

import '../../../domain/entities/dashboard/dashboard.dart';
import '../../../domain/errors/dashboard_errors.dart';
import '../dashboard/dashboard_datasource.dart';

/// Pure-Dart in-memory dashboard store (FR-002): the shared state behind
/// the in-memory datasource adapter, so the whole dashboard layer — and
/// every host app's dashboard logic — runs and tests without a platform.
///
/// Used as the default store wired by `registerDashboardDependencies`;
/// swap in backed implementations of the same datasource contract for
/// production persistence.
class InMemoryDashboardStore {
  final Map<String, Dashboard> dashboards = {};

  /// Removes every stored dashboard (useful between tests).
  void clear() {
    dashboards.clear();
  }
}

/// Shared helpers for the in-memory datasource adapters (sibling idiom).
class InMemoryStoreOps {
  static ZuraffaPlatformException notFound(String what) =>
      ZuraffaPlatformException(
        code: 'not_found',
        message: 'No $what matches the query.',
      );

  static String require(Map<String, dynamic>? params, String key) {
    final value = params?[key];
    if (value is String && value.isNotEmpty) return value;
    throw ZuraffaPlatformException(
      code: 'invalid_query',
      message: 'Query is missing the required "$key" parameter.',
    );
  }
}

/// The in-memory [DashboardDataSource]: reads and writes through the
/// shared [InMemoryDashboardStore].
class InMemoryDashboardDataSource
    with Loggable, FailureHandler
    implements DashboardDataSource {
  InMemoryDashboardDataSource(this.store);

  final InMemoryDashboardStore store;

  @override
  Future<Dashboard> get(QueryParams<Dashboard> params) async {
    final id = InMemoryStoreOps.require(params.params, 'id');
    final dashboard = store.dashboards[id];
    if (dashboard == null) throw DashboardNotFoundException(id);
    return dashboard;
  }

  @override
  Future<List<Dashboard>> getList(ListQueryParams<Dashboard> params) async {
    final owner = params.params?['owner'];
    final all = store.dashboards.values.toList(growable: false);
    // ListDashboardsUseCase contract: an unknown owner yields an empty list,
    // never every owner's dashboards.
    if (owner is! String || owner.isEmpty) return const <Dashboard>[];
    return all.where((d) => d.owner == owner).toList(growable: false);
  }

  @override
  Future<Dashboard> update(Dashboard dashboard) async {
    store.dashboards[dashboard.id] = dashboard;
    return dashboard;
  }

  @override
  Future<Dashboard> create(Dashboard dashboard) async {
    if (store.dashboards.containsKey(dashboard.id)) {
      throw DuplicateDashboardException(dashboard.id);
    }
    store.dashboards[dashboard.id] = dashboard;
    return dashboard;
  }
}
