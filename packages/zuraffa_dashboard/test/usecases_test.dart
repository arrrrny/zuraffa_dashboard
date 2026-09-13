import 'package:test/test.dart';
import 'package:zuraffa/zuraffa.dart' show ListQueryParams, QueryParams;
import 'package:zuraffa_dashboard/zuraffa_dashboard.dart';

const kMain = 'main';
const kOwner = 'user-1';
const kTile = 'tile.sales';

/// Shared repository wired over a fresh in-memory store per call.
DashboardRepository repositoryForTest() =>
    DataDashboardRepository(InMemoryDashboardDataSource(InMemoryDashboardStore()));

/// Feature `001-v6-dashboard-migration` — the nine dashboard use cases
/// (FR-003), exercised against the in-memory store.
void main() {
  group('create dashboard (FR-003)', () {
    test('creates and persists; duplicate id fails typed; empty fields rejected',
        () async {
      final repository = repositoryForTest();
      final useCase = CreateDashboardUseCase(repository);

      final board = await useCase.execute(
        const CreateDashboardParams(id: kMain, title: 'Main', owner: kOwner),
        null,
      );
      expect(board.id, kMain, reason: 'the created board is returned');
      expect(board.isDefault, isFalse, reason: 'created boards are not defaults');

      final listed = await repository.getList(
        ListQueryParams<Dashboard>(params: {'owner': kOwner}),
      );
      expect(listed, hasLength(1), reason: 'the board is persisted');

      await expectLater(
        useCase.execute(
          const CreateDashboardParams(id: kMain, title: 'Other', owner: kOwner),
          null,
        ),
        throwsA(isA<DuplicateDashboardException>()),
        reason: 'a duplicate dashboard id fails typed',
      );
      await expectLater(
        useCase.execute(
          const CreateDashboardParams(id: '', title: 'X', owner: kOwner),
          null,
        ),
        throwsArgumentError,
        reason: 'an empty id is rejected',
      );
      await expectLater(
        useCase.execute(
          const CreateDashboardParams(id: 'x', title: '', owner: kOwner),
          null,
        ),
        throwsArgumentError,
        reason: 'an empty title is rejected',
      );
      await expectLater(
        useCase.execute(
          const CreateDashboardParams(id: 'x', title: 'X', owner: ''),
          null,
        ),
        throwsArgumentError,
        reason: 'an empty owner is rejected',
      );
    });
  });

  group('list dashboards (FR-003)', () {
    test('lists the owner dashboards; an unknown owner yields an empty list',
        () async {
      final repository = repositoryForTest();
      final create = CreateDashboardUseCase(repository);
      await create.execute(
        const CreateDashboardParams(id: 'a', title: 'A', owner: kOwner),
        null,
      );
      await create.execute(
        const CreateDashboardParams(id: 'b', title: 'B', owner: 'user-2'),
        null,
      );
      final useCase = ListDashboardsUseCase(repository);

      final mine = await useCase.execute(
        const ListDashboardsParams(owner: kOwner),
        null,
      );
      expect(mine, hasLength(1), reason: 'only the owner boards return');
      expect(mine.first.id, 'a', reason: 'the matching board is returned');

      final theirs = await useCase.execute(
        const ListDashboardsParams(owner: 'nobody'),
        null,
      );
      expect(theirs, isEmpty, reason: 'unknown owner yields an empty list');
    });
  });

  group('get dashboard (FR-003)', () {
    test('returns the stored board; an unknown id raises the typed error',
        () async {
      final repository = repositoryForTest();
      await repository.create(Dashboard(
        id: kMain,
        title: 'Main',
        owner: kOwner,
        tiles: const [],
        isDefault: false,
      ));
      final useCase = GetDashboardUseCase(repository);

      final board = await useCase.execute(
        const GetDashboardParams(id: kMain),
        null,
      );
      expect(board.id, kMain, reason: 'the stored board is returned');

      await expectLater(
        useCase.execute(const GetDashboardParams(id: 'missing'), null),
        throwsA(isA<DashboardNotFoundException>()),
        reason: 'an unknown id raises the typed not-found error',
      );
    });
  });

  group('add tile (FR-003)', () {
    test('appends the tile and persists; duplicate tile id fails typed',
        () async {
      final repository = repositoryForTest();
      final create = CreateDashboardUseCase(repository);
      await create.execute(
        const CreateDashboardParams(id: kMain, title: 'Main', owner: kOwner),
        null,
      );
      final useCase = AddTileUseCase(repository);

      final tile = DashboardTile(
        id: kTile,
        type: 'chart.sales',
        title: 'Sales',
        placement: TilePlacement.create(
          row: 0,
          column: 0,
          rowSpan: 1,
          colSpan: 2,
        ),
        enabled: true,
        config: const {'metric': 'revenue'},
      );
      final board = await useCase.execute(
        AddTileParams(dashboardId: kMain, tile: tile),
        null,
      );
      expect(board.tiles, hasLength(1), reason: 'the tile is appended');

      final stored = await repository.get(
        QueryParams<Dashboard>(params: {'id': kMain}),
      );
      expect(stored.tiles, hasLength(1), reason: 'the mutation persists');

      await expectLater(
        useCase.execute(AddTileParams(dashboardId: kMain, tile: tile), null),
        throwsA(isA<DuplicateTileException>()),
        reason: 'a duplicate tile id fails typed',
      );
      await expectLater(
        useCase.execute(
          AddTileParams(dashboardId: 'missing', tile: tile),
          null,
        ),
        throwsA(isA<DashboardNotFoundException>()),
        reason: 'an unknown dashboard raises the typed error',
      );
    });
  });

  group('remove tile (FR-003)', () {
    test('removes the tile; an unknown tile id raises the typed error',
        () async {
      final repository = repositoryForTest();
      final create = CreateDashboardUseCase(repository);
      await create.execute(
        const CreateDashboardParams(id: kMain, title: 'Main', owner: kOwner),
        null,
      );
      final tile = DashboardTile(
        id: kTile,
        type: 'chart.sales',
        title: 'Sales',
        placement: TilePlacement.create(
          row: 0,
          column: 0,
          rowSpan: 1,
          colSpan: 1,
        ),
        enabled: true,
        config: const {},
      );
      final add = AddTileUseCase(repository);
      await add.execute(AddTileParams(dashboardId: kMain, tile: tile), null);
      final useCase = RemoveTileUseCase(repository);

      final board = await useCase.execute(
        const RemoveTileParams(dashboardId: kMain, tileId: kTile),
        null,
      );
      expect(board.tiles, isEmpty, reason: 'the tile is removed');

      await expectLater(
        useCase.execute(
          const RemoveTileParams(dashboardId: kMain, tileId: kTile),
          null,
        ),
        throwsA(isA<TileNotFoundException>()),
        reason: 'removing an absent tile raises the typed error',
      );
    });
  });

  group('move tile (FR-003)', () {
    test('updates row and column; an unknown tile raises the typed error',
        () async {
      final repository = repositoryForTest();
      final create = CreateDashboardUseCase(repository);
      await create.execute(
        const CreateDashboardParams(id: kMain, title: 'Main', owner: kOwner),
        null,
      );
      final tile = DashboardTile(
        id: kTile,
        type: 'chart.sales',
        title: 'Sales',
        placement: TilePlacement.create(
          row: 0,
          column: 0,
          rowSpan: 1,
          colSpan: 1,
        ),
        enabled: true,
        config: const {},
      );
      await AddTileUseCase(repository).execute(
        AddTileParams(dashboardId: kMain, tile: tile),
        null,
      );
      final useCase = MoveTileUseCase(repository);

      final board = await useCase.execute(
        const MoveTileParams(dashboardId: kMain, tileId: kTile, row: 2, column: 3),
        null,
      );
      expect(board.tiles.first.placement.row, 2, reason: 'row updated');
      expect(board.tiles.first.placement.column, 3, reason: 'column updated');
      expect(
        board.tiles.first.placement.rowSpan,
        1,
        reason: 'spans unchanged by a move',
      );

      await expectLater(
        useCase.execute(
          const MoveTileParams(
            dashboardId: kMain,
            tileId: 'missing',
            row: 1,
            column: 1,
          ),
          null,
        ),
        throwsA(isA<TileNotFoundException>()),
        reason: 'an unknown tile raises the typed error',
      );
    });
  });

  group('resize tile (FR-003)', () {
    test('updates spans with boundary enforcement; unknown tile typed error',
        () async {
      final repository = repositoryForTest();
      final create = CreateDashboardUseCase(repository);
      await create.execute(
        const CreateDashboardParams(id: kMain, title: 'Main', owner: kOwner),
        null,
      );
      final tile = DashboardTile(
        id: kTile,
        type: 'chart.sales',
        title: 'Sales',
        placement: TilePlacement.create(
          row: 1,
          column: 1,
          rowSpan: 1,
          colSpan: 1,
        ),
        enabled: true,
        config: const {},
      );
      await AddTileUseCase(repository).execute(
        AddTileParams(dashboardId: kMain, tile: tile),
        null,
      );
      final useCase = ResizeTileUseCase(repository);

      final board = await useCase.execute(
        const ResizeTileParams(
          dashboardId: kMain,
          tileId: kTile,
          rowSpan: 2,
          colSpan: 3,
        ),
        null,
      );
      expect(board.tiles.first.placement.rowSpan, 2, reason: 'rowSpan updated');
      expect(board.tiles.first.placement.colSpan, 3, reason: 'colSpan updated');
      expect(board.tiles.first.placement.row, 1, reason: 'row unchanged');

      await expectLater(
        useCase.execute(
          const ResizeTileParams(
            dashboardId: kMain,
            tileId: kTile,
            rowSpan: 0,
            colSpan: 1,
          ),
          null,
        ),
        throwsArgumentError,
        reason: 'rowSpan 0 is below the minimum 1',
      );
      await expectLater(
        useCase.execute(
          const ResizeTileParams(
            dashboardId: kMain,
            tileId: 'missing',
            rowSpan: 1,
            colSpan: 1,
          ),
          null,
        ),
        throwsA(isA<TileNotFoundException>()),
        reason: 'an unknown tile raises the typed error',
      );
    });
  });

  group('save dashboard (FR-003)', () {
    test('persists the board through the repository and the port', () async {
      final repository = repositoryForTest();
      final port = InMemoryDashboardAdapter();
      final create = CreateDashboardUseCase(repository);
      await create.execute(
        const CreateDashboardParams(id: kMain, title: 'Main', owner: kOwner),
        null,
      );
      final tile = DashboardTile(
        id: kTile,
        type: 'chart.sales',
        title: 'Sales',
        placement: TilePlacement.create(
          row: 0,
          column: 0,
          rowSpan: 1,
          colSpan: 1,
        ),
        enabled: true,
        config: const {},
      );
      final board = await AddTileUseCase(repository).execute(
        AddTileParams(dashboardId: kMain, tile: tile),
        null,
      );
      final useCase = SaveDashboardUseCase(repository, port);

      await useCase.execute(SaveDashboardParams(dashboard: board), null);

      final stored = await repository.get(
        QueryParams<Dashboard>(params: {'id': kMain}),
      );
      expect(stored.tiles, hasLength(1), reason: 'repository holds the board');

      final layouts = await port.loadLayouts();
      expect(layouts[kMain], hasLength(1), reason: 'port holds the layout');
      expect(layouts[kMain]!.first.id, kTile, reason: 'layout tile intact');
    });
  });
}
