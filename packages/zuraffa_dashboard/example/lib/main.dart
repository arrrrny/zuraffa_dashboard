import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:zuraffa_dashboard/zuraffa_dashboard.dart';

final GetIt getIt = GetIt.instance;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  registerDashboardDependencies(getIt);
  final dashboards = getIt<DashboardService>();

  // The documented journey: create → add → move → save.
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
  board = await dashboards.moveTile(board.id, 'tile.sales', row: 1, column: 1);
  await dashboards.save(board);

  runApp(DashboardExampleApp(service: dashboards));
}

/// The example host: lists the demo user's boards and their tiles.
class DashboardExampleApp extends StatelessWidget {
  const DashboardExampleApp({super.key, required this.service});

  final DashboardService service;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'zuraffa_dashboard example',
      home: Scaffold(
        appBar: AppBar(title: const Text('zuraffa_dashboard example')),
        body: FutureBuilder<List<Dashboard>>(
          future: service.list('demo-user'),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final boards = snapshot.data!;
            return ListView(
              children: [
                for (final board in boards)
                  ListTile(
                    key: Key('board-${board.id}'),
                    title: Text(board.title),
                    subtitle: Text(
                      '${board.tiles.length} tile(s) — owner ${board.owner}',
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
