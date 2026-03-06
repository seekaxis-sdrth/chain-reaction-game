import 'package:flutter/material.dart';
import '../models/cell.dart';
import '../models/player.dart';
import 'orb_painter.dart';

class CellWidget extends StatefulWidget {
  final Cell cell;
  final int criticalMass;
  final bool canPlace;
  final bool isCurrentPlayerCell;
  final VoidCallback onTap;
  final List<Player> players;
  final Color turnColor;

  const CellWidget({
    super.key,
    required this.cell,
    required this.criticalMass,
    required this.canPlace,
    required this.isCurrentPlayerCell,
    required this.onTap,
    required this.players,
    required this.turnColor,
  });

  @override
  State<CellWidget> createState() => _CellWidgetState();
}

class _CellWidgetState extends State<CellWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _cellColor {
    if (widget.cell.owner != null) {
      return widget.players[widget.cell.owner!].color;
    }
    return Colors.transparent;
  }

  bool get _isAboutToExplode =>
      !widget.cell.isEmpty &&
      widget.cell.orbs == widget.criticalMass - 1;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.canPlace ? widget.onTap : null,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: widget.turnColor.withValues(alpha: 0.2),
                width: 0.5,
              ),
              color: widget.canPlace && widget.cell.isEmpty
                  ? widget.turnColor.withValues(alpha: 0.06)
                  : Colors.transparent,
            ),
            child: Stack(
              children: [
                if (_isAboutToExplode)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: _cellColor.withValues(
                          alpha: 0.1 + 0.08 * _controller.value,
                        ),
                      ),
                    ),
                  ),
                if (!widget.cell.isEmpty)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: OrbPainter(
                        orbCount: widget.cell.orbs,
                        color: _cellColor,
                        animationValue: _controller.value,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
