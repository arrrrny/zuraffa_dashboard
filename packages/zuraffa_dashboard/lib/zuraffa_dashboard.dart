/// zuraffa_dashboard — typed, persistence-backed dashboard layouts for
/// the Zuraffa ecosystem.
///
/// Clean architecture end to end: Zuraffa entities
/// ([Dashboard], [DashboardTile], [TilePlacement]), a
/// [DashboardRepository] over Zuraffa datasources, nine business-logic
/// use cases, and a [DashboardService] facade wired through GetIt by
/// [registerDashboardDependencies]. Platform adapters
/// (zuraffa_dashboard_android/ios/macos) implement the [DashboardPort]
/// as federated siblings; without them layouts persist in memory for the
/// process lifetime.
///
/// Built on the Zuraffa framework (issue #673, EPIC #214).
///
/// ```dart
/// final getIt = GetIt.instance;
/// registerDashboardDependencies(getIt);
/// final dashboards = getIt<DashboardService>();
/// ```
library;

export 'package:zuraffa/zuraffa.dart' show GetIt;

export 'src/dashboard_service.dart';
export 'src/data/datasources/dashboard_store/in_memory_dashboard_store.dart';
export 'src/data/dashboard/in_memory_dashboard_adapter.dart';
export 'src/data/repositories/data_dashboard_repository.dart';
export 'src/domain/dashboard_port.dart';
export 'src/domain/entities/dashboard/dashboard.dart';
export 'src/domain/entities/dashboard_tile/dashboard_tile.dart';
export 'src/domain/entities/tile_placement/tile_placement.dart';
export 'src/domain/errors/dashboard_errors.dart';
export 'src/di/dashboard_di.dart';
export 'src/domain/repositories/dashboard_repository.dart';
export 'src/domain/usecases/dashboard/create_dashboard_usecase.dart';
export 'src/domain/usecases/dashboard/list_dashboards_usecase.dart';
export 'src/domain/usecases/dashboard/get_dashboard_usecase.dart';
export 'src/domain/usecases/dashboard/add_tile_usecase.dart';
export 'src/domain/usecases/dashboard/remove_tile_usecase.dart';
export 'src/domain/usecases/dashboard/move_tile_usecase.dart';
export 'src/domain/usecases/dashboard/resize_tile_usecase.dart';
export 'src/domain/usecases/dashboard/save_dashboard_usecase.dart';
export 'src/domain/usecases/dashboard/reset_dashboard_usecase.dart';

// Layers land with their tasks; the export list completes at T026/T031.
