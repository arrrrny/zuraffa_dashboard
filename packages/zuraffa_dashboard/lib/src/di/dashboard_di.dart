import 'package:zuraffa/zuraffa.dart';

import '../dashboard_service.dart';
import '../data/dashboard/in_memory_dashboard_adapter.dart';
import '../data/datasources/dashboard/dashboard_datasource.dart';
import '../data/datasources/dashboard_store/in_memory_dashboard_store.dart';
import '../data/repositories/data_dashboard_repository.dart';
import '../domain/dashboard_port.dart';
import '../domain/repositories/dashboard_repository.dart';
import '../domain/usecases/dashboard/add_tile_usecase.dart';
import '../domain/usecases/dashboard/create_dashboard_usecase.dart';
import '../domain/usecases/dashboard/get_dashboard_usecase.dart';
import '../domain/usecases/dashboard/list_dashboards_usecase.dart';
import '../domain/usecases/dashboard/move_tile_usecase.dart';
import '../domain/usecases/dashboard/remove_tile_usecase.dart';
import '../domain/usecases/dashboard/resize_tile_usecase.dart';
import '../domain/usecases/dashboard/reset_dashboard_usecase.dart';
import '../domain/usecases/dashboard/save_dashboard_usecase.dart';

/// Optional factory installed by a federated platform package so apps get
/// real on-device layout persistence without wiring the adapter by hand.
///
/// `zuraffa_dashboard_android` / `_ios` / `_macos` call
/// [setPlatformDashboardPortFactory] from their `registerWith()` (which
/// Flutter runs when the app starts). Until one does, the package stays
/// pure Dart and defaults to [InMemoryDashboardAdapter] — so it tests
/// without a platform (FR-005) and consumers can still inject a custom
/// [DashboardPort].
DashboardPort? Function()? _platformDashboardPortFactory;

/// Called by a platform package at registration time to supply the real
/// [DashboardPort] (bridged onto its native [ZuraffaDashboardPlatform]).
void setPlatformDashboardPortFactory(DashboardPort Function() factory) {
  _platformDashboardPortFactory = factory;
}

/// The default [DashboardPort] when the caller injects none: the platform
/// package's real adapter if one registered, otherwise the in-memory
/// default.
DashboardPort _defaultDashboardPort() =>
    _platformDashboardPortFactory?.call() ?? InMemoryDashboardAdapter();

/// Registers the dashboard stack onto [getIt] (FR-004).
///
/// ```dart
/// final getIt = GetIt.instance;
/// registerDashboardDependencies(getIt);
/// final dashboards = getIt<DashboardService>();
/// ```
void registerDashboardDependencies(
  GetIt getIt, {
  DashboardPort? port,
  DashboardRepository? repository,
  DashboardDataSource? dataSource,
}) {
  getIt
    ..registerLazySingleton<DashboardPort>(() => port ?? _defaultDashboardPort())
    ..registerLazySingleton<DashboardDataSource>(
      () => dataSource ?? InMemoryDashboardDataSource(InMemoryDashboardStore()),
    )
    ..registerLazySingleton<DashboardRepository>(
      () => repository ??
          DataDashboardRepository(getIt<DashboardDataSource>()),
    )
    // FR-003: every business-logic use case resolves from the container.
    ..registerLazySingleton<CreateDashboardUseCase>(
      () => CreateDashboardUseCase(getIt<DashboardRepository>()),
    )
    ..registerLazySingleton<ListDashboardsUseCase>(
      () => ListDashboardsUseCase(getIt<DashboardRepository>()),
    )
    ..registerLazySingleton<GetDashboardUseCase>(
      () => GetDashboardUseCase(getIt<DashboardRepository>()),
    )
    ..registerLazySingleton<SaveDashboardUseCase>(
      () => SaveDashboardUseCase(
        getIt<DashboardRepository>(),
        getIt<DashboardPort>(),
      ),
    )
    ..registerLazySingleton<AddTileUseCase>(
      () => AddTileUseCase(getIt<DashboardRepository>()),
    )
    ..registerLazySingleton<RemoveTileUseCase>(
      () => RemoveTileUseCase(getIt<DashboardRepository>()),
    )
    ..registerLazySingleton<MoveTileUseCase>(
      () => MoveTileUseCase(getIt<DashboardRepository>()),
    )
    ..registerLazySingleton<ResizeTileUseCase>(
      () => ResizeTileUseCase(getIt<DashboardRepository>()),
    )
    ..registerLazySingleton<ResetDashboardUseCase>(
      () => ResetDashboardUseCase(
        getIt<DashboardRepository>(),
        getIt<DashboardPort>(),
      ),
    )
    ..registerLazySingleton<DashboardService>(
      () => DashboardService(
        port: getIt<DashboardPort>(),
        repository: getIt<DashboardRepository>(),
      ),
    );
}
