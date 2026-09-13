import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zuraffa_dashboard/zuraffa_dashboard.dart';
import 'package:example/main.dart' as app;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('the documented dashboard journey runs in a real host',
      (tester) async {
    // A fresh container so the example's global is not touched by tests.
    final getIt = GetIt.asNewInstance();
    registerDashboardDependencies(getIt);
    final dashboards = getIt<DashboardService>();

    // create → add → move → save (the same journey main() runs).
    var board = await dashboards.create(
      id: 'main',
      title: 'Main',
      owner: 'demo-user',
    );
    board = await dashboards.addTile(
      board.id,
      DashboardTile(
        id: 'tile.sales',
        type: 'chart.sales',
        title: 'Sales',
        placement: TilePlacement.create(
          row: 0,
          column: 0,
          rowSpan: 1,
          colSpan: 2,
        ),
        enabled: true,
        config: {'metric': 'revenue'},
      ),
    );
    board =
        await dashboards.moveTile(board.id, 'tile.sales', row: 1, column: 1);
    await dashboards.save(board);

    // The saved layout reads back through the port snapshot.
    final layouts = await dashboards.layouts();
    expect(layouts['main'], hasLength(1), reason: 'the save persisted');
    expect(layouts['main']!.first.placement.row, 1, reason: 'moved to row 1');

    // The host renders the board and its journey state.
    await tester.pumpWidget(app.DashboardExampleApp(service: dashboards));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey<String>('board-main')), findsOneWidget);
  });
}
