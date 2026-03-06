import 'dart:async';
import 'package:flutter/foundation.dart';
import 'cell.dart';
import 'player.dart';

class GameState extends ChangeNotifier {
  final int rows;
  final int cols;
  final List<Player> players;
  late List<List<Cell>> grid;
  int _currentPlayerIndex = 0;
  bool _isAnimating = false;
  int _turnCount = 0;
  int? _winnerId;
  int _generation = 0;
  final List<List<int>> _explosionQueue = [];

  GameState({
    required this.rows,
    required this.cols,
    required int playerCount,
  }) : players = Player.createPlayers(playerCount) {
    _initGrid();
  }

  int get currentPlayerIndex => _currentPlayerIndex;
  Player get currentPlayer => players[_currentPlayerIndex];
  bool get isAnimating => _isAnimating;
  int get turnCount => _turnCount;
  int? get winnerId => _winnerId;
  bool get isGameOver => _winnerId != null;

  int get alivePlayerCount => players.where((p) => p.isAlive).length;

  void _initGrid() {
    grid = List.generate(
      rows,
      (r) => List.generate(cols, (c) => Cell()),
    );
  }

  int criticalMass(int row, int col) {
    int mass = 4;
    if (row == 0 || row == rows - 1) mass--;
    if (col == 0 || col == cols - 1) mass--;
    return mass;
  }

  bool canPlace(int row, int col) {
    if (_isAnimating || isGameOver) return false;
    final cell = grid[row][col];
    return cell.isEmpty || cell.owner == currentPlayer.id;
  }

  Future<void> placeOrb(int row, int col) async {
    if (!canPlace(row, col)) return;

    final gen = _generation;

    _isAnimating = true;
    notifyListeners();

    grid[row][col].orbs++;
    grid[row][col].owner = currentPlayer.id;
    notifyListeners();

    await _processExplosions(row, col, gen);

    if (gen != _generation) return;

    _isAnimating = false;
    _turnCount++;

    _checkEliminations();

    if (!isGameOver) {
      _nextPlayer();
    }

    notifyListeners();
  }

  Future<void> _processExplosions(int startRow, int startCol, int gen) async {
    _explosionQueue.clear();

    if (grid[startRow][startCol].orbs >= criticalMass(startRow, startCol)) {
      _explosionQueue.add([startRow, startCol]);
    }

    int safetyCounter = 0;
    const maxIterations = 1000;

    while (_explosionQueue.isNotEmpty && safetyCounter < maxIterations) {
      if (gen != _generation) return;

      safetyCounter++;
      final current = _explosionQueue.removeAt(0);
      final r = current[0];
      final c = current[1];

      if (grid[r][c].orbs < criticalMass(r, c)) continue;

      final owner = grid[r][c].owner;
      grid[r][c].orbs -= criticalMass(r, c);
      if (grid[r][c].orbs == 0) {
        grid[r][c].owner = null;
      }

      final neighbors = _getNeighbors(r, c);
      for (final n in neighbors) {
        final nr = n[0];
        final nc = n[1];
        grid[nr][nc].orbs++;
        grid[nr][nc].owner = owner;

        if (grid[nr][nc].orbs >= criticalMass(nr, nc)) {
          _explosionQueue.add([nr, nc]);
        }
      }

      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 80));

      if (gen != _generation) return;
      if (_checkWinCondition()) return;
    }
  }

  List<List<int>> _getNeighbors(int row, int col) {
    final neighbors = <List<int>>[];
    if (row > 0) neighbors.add([row - 1, col]);
    if (row < rows - 1) neighbors.add([row + 1, col]);
    if (col > 0) neighbors.add([row, col - 1]);
    if (col < cols - 1) neighbors.add([row, col + 1]);
    return neighbors;
  }

  void _checkEliminations() {
    if (_turnCount < players.length) return;

    for (final player in players) {
      if (!player.isAlive) continue;
      final hasOrbs = grid.any(
        (row) => row.any((cell) => cell.owner == player.id && cell.orbs > 0),
      );
      if (!hasOrbs) {
        player.isAlive = false;
      }
    }

    _checkWinCondition();
  }

  bool _checkWinCondition() {
    if (_turnCount < players.length) return false;

    final alivePlayers = players.where((p) => p.isAlive).toList();
    if (alivePlayers.length == 1) {
      _winnerId = alivePlayers.first.id;
      return true;
    }
    return false;
  }

  void _nextPlayer() {
    do {
      _currentPlayerIndex = (_currentPlayerIndex + 1) % players.length;
    } while (!currentPlayer.isAlive);
  }

  void reset() {
    _generation++;
    _currentPlayerIndex = 0;
    _turnCount = 0;
    _winnerId = null;
    _isAnimating = false;
    _explosionQueue.clear();
    for (final player in players) {
      player.isAlive = true;
    }
    _initGrid();
    notifyListeners();
  }
}
