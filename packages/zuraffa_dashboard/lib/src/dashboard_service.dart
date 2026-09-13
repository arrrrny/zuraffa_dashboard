import 'domain/dashboard_port.dart';
import 'domain/entities/dashboard/dashboard.dart';
import 'domain/entities/dashboard_tile/dashboard_tile.dart';
import 'domain/repositories/dashboard_repository.dart';
import 'domain/usecases/dashboard/add_tile_usecase.dart';
import 'domain/usecases/dashboard/create_dashboard_usecase.dart';
import 'domain/usecases/dashboard/get_dashboard_usecase.dart';
import 'domain/usecases/dashboard/list_dashboards_usecase.dart';
import 'domain/usecases/dashboard/move_tile_usecase.dart';
import 'domain/usecases/dashboard/remove_tile_usecase.dart';
import 'domain/usecases/dashboard/resize_tile_usecase.dart';
import 'domain/usecases/dashboard/reset_dashboard_usecase.dart';
import 'domain/usecases/dashboard/save_dashboard_usecase.dart';

/// The dashboard facade (FR-004): every common journey one call away,
/// backed by the use cases. Hosts resolve this from GetIt after
/// [registerDashboardDependencies].
class DashboardService {
  DashboardService({required DashboardPort port, required DashboardRepository repository})
    : _port = port,
      _create = CreateDashboardUseCase(repository),
      _list = ListDashboardsUseCase(repository),
      _get = GetDashboardUseCase(repository),
      _save = SaveDashboardUseCase(repository, port),
      _addTile = AddTileUseCase(repository),
      _removeTile = RemoveTileUseCase(repository),
      _moveTile = MoveTileUseCase(repository),
      _resizeTile = ResizeTileUseCase(repository),
      _reset = ResetDashboardUseCase(repository, port);

  final DashboardPort _port;
  final CreateDashboardUseCase _create;
  final ListDashboardsUseCase _list;
  final GetDashboardUseCase _get;
  final SaveDashboardUseCase _save;
  final AddTileUseCase _addTile;
  final RemoveTileUseCase _removeTile;
  final MoveTileUseCase _moveTile;
  final ResizeTileUseCase _resizeTile;
  final ResetDashboardUseCase _reset;

  /// Creates and persists an empty board.
  Future<Dashboard> create({
    required String id,
    required String title,
    required String owner,
  }) =>
      _create.execute(CreateDashboardParams(id: id, title: title, owner: owner), null);

  /// Lists the boards owned by [owner].
  Future<List<Dashboard>> list(String owner) =>
      _list.execute(ListDashboardsParams(owner: owner), null);

  /// Loads the board with [id].
  Future<Dashboard> get(String id) => _get.execute(GetDashboardParams(id: id), null);

  /// Persists the board through the repository and the port.
  Future<void> save(Dashboard dashboard) =>
      _save.execute(SaveDashboardParams(dashboard: dashboard), null);

  /// Appends [tile] to the board [dashboardId].
  Future<Dashboard> addTile(String dashboardId, DashboardTile tile) =>
      _addTile.execute(AddTileParams(dashboardId: dashboardId, tile: tile), null);

  /// Removes the tile [tileId] from the board [dashboardId].
  Future<Dashboard> removeTile(String dashboardId, String tileId) =>
      _removeTile.execute(RemoveTileParams(dashboardId: dashboardId, tileId: tileId), null);

  /// Moves the tile [tileId] to [row]/[column].
  Future<Dashboard> moveTile(
    String dashboardId,
    String tileId, {
    required int row,
    required int column,
  }) =>
      _moveTile.execute(MoveTileParams(
        dashboardId: dashboardId,
        tileId: tileId,
        row: row,
        column: column,
      ), null);

  /// Resizes the tile [tileId] to [rowSpan] x [colSpan].
  Future<Dashboard> resizeTile(
    String dashboardId,
    String tileId, {
    required int rowSpan,
    required int colSpan,
  }) =>
      _resizeTile.execute(ResizeTileParams(
        dashboardId: dashboardId,
        tileId: tileId,
        rowSpan: rowSpan,
        colSpan: colSpan,
      ), null);

  /// Restores the board [dashboardId] to the owner's default template.
  Future<Dashboard> reset(String dashboardId) =>
      _reset.execute(ResetDashboardParams(dashboardId: dashboardId), null);

  /// The persisted layouts mirrored through the port (diagnostics).
  Future<Map<String, List<DashboardTile>>> layouts() => _port.loadLayouts();
}
