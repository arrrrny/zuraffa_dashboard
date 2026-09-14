import 'package:flutter/material.dart';
import 'package:zuraffa_dashboard/zuraffa_dashboard.dart';

/// Renders dashboard tiles on an absolutely-positioned grid that honors
/// each tile's [TilePlacement] (row, column, rowSpan, colSpan). Tiles are
/// draggable onto other tiles (positions swap) and removable.
class DashboardGrid extends StatelessWidget {
  const DashboardGrid({
    super.key,
    required this.tiles,
    required this.onMove,
    required this.onRemove,
    this.columns = 4,
  });

  final List<DashboardTile> tiles;
  final Future<void> Function(DashboardTile tile, int row, int column) onMove;
  final void Function(DashboardTile tile) onRemove;
  final int columns;

  static const double _gap = 12;
  static const double _rowHeight = 150;

  @override
  Widget build(BuildContext context) {
    final maxRow = tiles.fold<int>(
      1,
      (max, t) => t.placement.row + t.placement.rowSpan > max
          ? t.placement.row + t.placement.rowSpan
          : max,
    );
    final contentHeight = maxRow * _rowHeight + (maxRow + 1) * _gap;

    return LayoutBuilder(
      builder: (context, constraints) {
        final cellWidth =
            (constraints.maxWidth - (columns + 1) * _gap) / columns;
        return SingleChildScrollView(
          child: SizedBox(
            height: contentHeight,
            child: Stack(
              children: [
                for (final tile in tiles) _positionedFor(tile, cellWidth),
              ],
            ),
          ),
        );
      },
    );
  }

  Positioned _positionedFor(DashboardTile tile, double cellWidth) {
    final left = _gap + tile.placement.column * (cellWidth + _gap);
    final top = _gap + tile.placement.row * (_rowHeight + _gap);
    final width =
        tile.placement.colSpan * cellWidth + (tile.placement.colSpan - 1) * _gap;
    final height = tile.placement.rowSpan * _rowHeight +
        (tile.placement.rowSpan - 1) * _gap;

    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: DragTarget<String>(
        onAcceptWithDetails: (details) async {
          final draggedId = details.data;
          final target = tiles.where((t) => t.id == tile.id).firstOrNull;
          final dragged = tiles.where((t) => t.id == draggedId).firstOrNull;
          if (target == null || dragged == null || dragged.id == target.id) {
            return;
          }
          // Swap the two tiles' anchor cells, awaiting each mutation so the
          // second one sees the first's persisted state.
          await onMove(dragged, target.placement.row, target.placement.column);
          await onMove(target, dragged.placement.row, dragged.placement.column);
        },
        builder: (context, candidate, rejected) => TileCard(
          tile: tile,
          onRemove: () => onRemove(tile),
        ),
      ),
    );
  }
}

class TileCard extends StatelessWidget {
  const TileCard({super.key, required this.tile, required this.onRemove});

  final DashboardTile tile;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LongPressDraggable<String>(
      data: tile.id,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      feedback: FractionalTranslation(
        translation: const Offset(-0.5, -0.5),
        child: Opacity(opacity: 0.85, child: _scaffold(theme)),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: _scaffold(theme)),
      child: _scaffold(theme),
    );
  }

  Widget _scaffold(ThemeData theme) {
    return Card(
      elevation: 1.5,
      margin: EdgeInsets.zero,
      color: tile.enabled ? null : theme.disabledColor.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    tile.title,
                    style: theme.textTheme.titleSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                InkWell(onTap: onRemove, child: Icon(Icons.close, size: 16, color: theme.hintColor)),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(child: _body(theme)),
          ],
        ),
      ),
    );
  }

  Widget _body(ThemeData theme) {
    switch (tile.type) {
      case 'stat':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${tile.config['value'] ?? '—'}',
              style: theme.textTheme.headlineMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (tile.config['delta'] != null)
              Text(
                '${tile.config['delta']} vs last week',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: '${tile.config['delta']}'.startsWith('+')
                      ? Colors.green.shade700
                      : Colors.red.shade700,
                ),
              ),
          ],
        );
      case 'chart.bar':
        return _BarChart(
          values: _doubles(tile.config['values']),
          labels: _strings(tile.config['labels']),
        );
      case 'chart.line':
        return _LineChart(values: _doubles(tile.config['values']));
      case 'list':
        final items = _strings(tile.config['items']);
        return ListView(
          children: [
            for (var i = 0; i < items.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    Text('${i + 1}.', style: theme.textTheme.bodySmall),
                    const SizedBox(width: 6),
                    Expanded(
                        child: Text(items[i], overflow: TextOverflow.ellipsis)),
                  ],
                ),
              ),
          ],
        );
      default:
        return Text('Unknown type: ${tile.type}',
            style: theme.textTheme.bodySmall);
    }
  }

  List<double> _doubles(Object? raw) => (raw as List<Object?>? ?? const [])
      .map((v) => (v as num).toDouble())
      .toList();

  List<String> _strings(Object? raw) =>
      (raw as List<Object?>? ?? const []).map((v) => '$v').toList();
}

class _BarChart extends StatelessWidget {
  const _BarChart({required this.values, required this.labels});

  final List<double> values;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final max = values.fold(1.0, (m, v) => v > m ? v : m);
    return Stack(
      children: [
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: CustomPaint(painter: _BarPainter(values, max)),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (final label in labels)
                Text(label, style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
        ),
      ],
    );
  }
}

class _BarPainter extends CustomPainter {
  const _BarPainter(this.values, this.max);

  final List<double> values;
  final double max;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF4F6DF5);
    final slot = size.width / values.length;
    for (var i = 0; i < values.length; i++) {
      final barHeight = size.height * 0.95 * (values[i] / max);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(slot * i + slot * 0.15, size.height - barHeight,
              slot * 0.7, barHeight),
          const Radius.circular(4),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BarPainter old) => old.values != values;
}

class _LineChart extends StatelessWidget {
  const _LineChart({required this.values});

  final List<double> values;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _LinePainter(values));
  }
}

class _LinePainter extends CustomPainter {
  const _LinePainter(this.values);

  final List<double> values;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final max = values.fold(1.0, (m, v) => v > m ? v : m);
    final step = size.width / (values.length - 1);
    final path = Path()
      ..moveTo(0, size.height * (1 - values.first / max));
    for (var i = 1; i < values.length; i++) {
      path.lineTo(step * i, size.height * (1 - values[i] / max));
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF2BA84A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
  }

  @override
  bool shouldRepaint(covariant _LinePainter old) => old.values != values;
}
