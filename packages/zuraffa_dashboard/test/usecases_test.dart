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
}
