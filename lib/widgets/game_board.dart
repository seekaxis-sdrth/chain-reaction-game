import 'package:flutter/material.dart';
import '../models/game_state.dart';
import 'cell_widget.dart';

class GameBoard extends StatelessWidget {
  final GameState gameState;

  const GameBoard({super.key, required this.gameState});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: gameState,
      builder: (context, _) {
        final turnColor = gameState.currentPlayer.color;

        return AspectRatio(
          aspectRatio: gameState.cols / gameState.rows,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              border: Border.all(
                color: turnColor.withValues(alpha: 0.5),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: turnColor.withValues(alpha: 0.15),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: List.generate(gameState.rows, (row) {
                return Expanded(
                  child: Row(
                    children: List.generate(gameState.cols, (col) {
                      final cell = gameState.grid[row][col];
                      return Expanded(
                        child: CellWidget(
                          cell: cell,
                          criticalMass: gameState.criticalMass(row, col),
                          canPlace: gameState.canPlace(row, col),
                          isCurrentPlayerCell:
                              cell.owner == gameState.currentPlayer.id,
                          onTap: () => gameState.placeOrb(row, col),
                          players: gameState.players,
                          turnColor: turnColor,
                        ),
                      );
                    }),
                  ),
                );
              }),
            ),
          ),
        );
      },
    );
  }
}
