import 'package:flutter/material.dart';
import 'package:zuraffa_dashboard/zuraffa_dashboard.dart';

import 'dashboard_grid.dart';

final GetIt getIt = GetIt.instance;

/// The demo owner + board ids shared by the seeder and the UI.
const kOwner = 'demo-user';
const kBoardId = 'main';

/// The default template the Reset action restores (a board flagged
/// `isDefault` for the same owner — see ResetDashboardUseCase).
final defaultTemplateTiles = [
  DashboardTile(
    id: 'tile.revenue',
    type: 'stat',
    title: 'Revenue',
    placement: TilePlacement(row: 0, column: 0, rowSpan: 1, colSpan: 1),
    enabled: true,
    config: {'value': r'$48.2K', 'delta': '+12.4%'},
  ),
  DashboardTile(
    id: 'tile.sales',
    type: 'chart.bar',
    title: 'Sales by region',
    placement: TilePlacement(row: 0, column: 1, rowSpan: 1, colSpan: 2),
    enabled: true,
    config: {
      'values': [42, 68, 55, 90, 74],
      'labels': ['EU', 'US', 'APAC', 'LATAM', 'MEA'],
    },
  ),
  DashboardTile(
    id: 'tile.orders',
    type: 'stat',
    title: 'Orders',
    placement: TilePlacement(row: 0, column: 3, rowSpan: 1, colSpan: 1),
    enabled: true,
    config: {'value': '1,284', 'delta': '+3.1%'},
  ),
  DashboardTile(
    id: 'tile.users',
    type: 'chart.line',
    title: 'Active users',
    placement: TilePlacement(row: 1, column: 0, rowSpan: 1, colSpan: 1),
    enabled: true,
    config: {
      'values': [12, 30, 18, 45, 55, 48, 70],
    },
  ),
  DashboardTile(
    id: 'tile.top-products',
    type: 'list',
    title: 'Top products',
    placement: TilePlacement(row: 1, column: 1, rowSpan: 1, colSpan: 2),
    enabled: true,
    config: {
      'items': ['Zuraffa Hoodie', 'Clean Arch Mug', 'UseCase Sticker', 'GetIt Tee'],
    },
  ),
  DashboardTile(
    id: 'tile.customers',
    type: 'stat',
    title: 'New customers',
    placement: TilePlacement(row: 1, column: 3, rowSpan: 1, colSpan: 1),
    enabled: true,
    config: {'value': '312', 'delta': '-1.8%'},
  ),
];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  registerDashboardDependencies(getIt);
  final dashboards = getIt<DashboardService>();
  await bootstrap(dashboards);
  runApp(DashboardExampleApp(service: dashboards));
}

/// Restores the demo board from persisted layouts (via the port — on
/// device this is the native platform-preferences adapter), or seeds the
/// default template on first run.
Future<Dashboard> bootstrap(DashboardService dashboards) async {
  final layouts = await dashboards.layouts();
  try {
    return await dashboards.get(kBoardId);
  } on DashboardNotFoundException {
    final board = await dashboards.create(
      id: kBoardId,
      title: 'Sales Dashboard',
      owner: kOwner,
    );
    final tiles = layouts[kBoardId] ?? defaultTemplateTiles;
    var current = board;
    for (final tile in tiles) {
      try {
        current = await dashboards.addTile(board.id, tile);
      } on DuplicateTileException {
        // tile already on the board — nothing to do.
      }
    }
    await dashboards.save(current);
    return current;
  }
}

/// The example host: renders the persisted board as an interactive
/// dashboard grid (drag to move, add, remove, reset).
class DashboardExampleApp extends StatelessWidget {
  const DashboardExampleApp({super.key, required this.service});

  final DashboardService service;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'zuraffa_dashboard example',
      theme: ThemeData(colorSchemeSeed: const Color(0xFF4F6DF5), useMaterial3: true),
      home: DashboardPage(service: service),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key, required this.service});

  final DashboardService service;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Dashboard? _board;
  String _status = 'loading…';
  int _newTileCounter = 0;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final board = await widget.service.get(kBoardId);
    if (mounted) setState(() => _board = board);
  }

  Future<void> _persist(Dashboard board) async {
    await widget.service.save(board);
    if (mounted) {
      setState(() {
        _board = board;
        _status = 'saved ${TimeOfDay.now().format(context)}';
      });
    }
  }

  Future<void> _moveTile(DashboardTile tile, int row, int column) async {
    final board = _board;
    if (board == null) return;
    final updated = await widget.service.moveTile(
      board.id,
      tile.id,
      row: row,
      column: column,
    );
    await _persist(updated);
  }

  Future<void> _removeTile(DashboardTile tile) async {
    final board = _board;
    if (board == null) return;
    final updated = await widget.service.removeTile(board.id, tile.id);
    await _persist(updated);
  }

  Future<void> _addTile() async {
    final board = _board;
    if (board == null) return;
    final spot = _firstFreeCell(board);
    final demoTypes = ['stat', 'chart.bar', 'chart.line', 'list'];
    final type = demoTypes[_newTileCounter % demoTypes.length];
    _newTileCounter++;
    final tile = DashboardTile(
      id: 'tile.new_$_newTileCounter',
      type: type,
      title: 'New $type tile',
      placement: TilePlacement.create(
        row: spot.$1,
        column: spot.$2,
        rowSpan: 1,
        colSpan: type == 'stat' ? 1 : 2,
      ),
      enabled: true,
      config: type == 'stat'
          ? {'value': '42', 'delta': '+0.0%'}
          : type == 'list'
              ? {
                  'items': ['Fresh item A', 'Fresh item B'],
                }
              : {
                  'values': [20, 50, 35, 65, 45],
                },
    );
    final updated = await widget.service.addTile(board.id, tile);
    await _persist(updated);
  }

  Future<void> _reset() async {
    final board = _board;
    if (board == null) return;
    final updated = await widget.service.reset(board.id);
    await _persist(updated);
  }

  /// First (row, column) not covered by any tile.
  (int, int) _firstFreeCell(Dashboard board) {
    final occupied = <(int, int)>{
      for (final t in board.tiles)
        for (var r = 0; r < t.placement.rowSpan; r++)
          for (var c = 0; c < t.placement.colSpan; c++)
            (t.placement.row + r, t.placement.column + c),
    };
    for (var row = 0; row < 32; row++) {
      for (var column = 0; column < 4; column++) {
        if (!occupied.contains((row, column))) return (row, column);
      }
    }
    return (0, 0);
  }

  @override
  Widget build(BuildContext context) {
    final board = _board;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          board?.title ?? 'Dashboard',
          key: board == null ? null : ValueKey<String>('board-${board.id}'),
        ),
        actions: [
          IconButton(
            tooltip: 'Reset to template',
            onPressed: _reset,
            icon: const Icon(Icons.restart_alt),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(_status, style: Theme.of(context).textTheme.bodySmall),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addTile,
        icon: const Icon(Icons.add),
        label: const Text('Add tile'),
      ),
      body: board == null
          ? const Center(child: CircularProgressIndicator())
          : DashboardGrid(
              tiles: board.tiles,
              onMove: _moveTile,
              onRemove: _removeTile,
            ),
    );
  }
}
