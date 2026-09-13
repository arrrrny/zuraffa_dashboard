import 'package:test/test.dart';
import 'package:zuraffa/zuraffa.dart' show ListQueryParams;
import 'package:zuraffa_dashboard/zuraffa_dashboard.dart';

const kMain = 'main';
const kOwner = 'user-1';

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
}
