import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../widgets/game_board.dart';

class GameScreen extends StatefulWidget {
  final int playerCount;
  final int rows;
  final int cols;

  const GameScreen({
    super.key,
    required this.playerCount,
    this.rows = 9,
    this.cols = 6,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameState _gameState;
  bool _winDialogShown = false;

  @override
  void initState() {
    super.initState();
    _gameState = GameState(
      rows: widget.rows,
      cols: widget.cols,
      playerCount: widget.playerCount,
    );
  }

  @override
  void dispose() {
    _gameState.dispose();
    super.dispose();
  }

  void _showWinDialog() {
    final winner = _gameState.players[_gameState.winnerId!];
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          '🎉 Game Over!',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: winner.color,
                boxShadow: [
                  BoxShadow(
                    color: winner.color.withValues(alpha: 0.5),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${winner.name} Wins!',
              style: TextStyle(
                color: winner.color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'In ${_gameState.turnCount} turns',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _winDialogShown = false;
              _gameState.reset();
            },
            child: const Text('Play Again', style: TextStyle(fontSize: 16)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Main Menu', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F23),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text(
          'Chain Reaction',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Restart',
            onPressed: () {
              _winDialogShown = false;
              _gameState.reset();
            },
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _gameState,
        builder: (context, _) {
          if (_gameState.isGameOver && !_winDialogShown) {
            _winDialogShown = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_gameState.isGameOver) _showWinDialog();
            });
          }

          return Column(
            children: [
              _buildPlayerBar(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Center(
                    child: GameBoard(gameState: _gameState),
                  ),
                ),
              ),
              _buildStatusBar(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPlayerBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: const Color(0xFF1A1A2E),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _gameState.players.map((player) {
          final isCurrent =
              player.id == _gameState.currentPlayer.id && !_gameState.isGameOver;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isCurrent
                  ? player.color.withValues(alpha: 0.25)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: isCurrent
                  ? Border.all(color: player.color, width: 2)
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: player.isAlive
                        ? player.color
                        : player.color.withValues(alpha: 0.3),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  player.name,
                  style: TextStyle(
                    color: player.isAlive ? Colors.white : Colors.white38,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                    decoration:
                        player.isAlive ? null : TextDecoration.lineThrough,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatusBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF1A1A2E),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Turn: ${_gameState.turnCount + 1}',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          if (_gameState.isAnimating)
            const Row(
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white54,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  'Chain reaction...',
                  style: TextStyle(color: Colors.white54, fontSize: 14),
                ),
              ],
            ),
          Text(
            'Players alive: ${_gameState.alivePlayerCount}',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
