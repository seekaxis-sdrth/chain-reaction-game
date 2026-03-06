import 'package:flutter_test/flutter_test.dart';
import 'package:chain_reaction_game/models/cell.dart';
import 'package:chain_reaction_game/models/player.dart';
import 'package:chain_reaction_game/models/game_state.dart';

void main() {
  group('Cell', () {
    test('starts empty', () {
      final cell = Cell();
      expect(cell.isEmpty, true);
      expect(cell.orbs, 0);
      expect(cell.owner, null);
    });

    test('copyWith works correctly', () {
      final cell = Cell(orbs: 2, owner: 1);
      final copy = cell.copyWith(orbs: 3);
      expect(copy.orbs, 3);
      expect(copy.owner, 1);
    });

    test('copyWith clearOwner works', () {
      final cell = Cell(orbs: 0, owner: 1);
      final copy = cell.copyWith(clearOwner: true);
      expect(copy.owner, null);
    });
  });

  group('Player', () {
    test('createPlayers generates correct count', () {
      final players = Player.createPlayers(4);
      expect(players.length, 4);
      expect(players[0].id, 0);
      expect(players[3].id, 3);
    });

    test('players start alive', () {
      final players = Player.createPlayers(2);
      expect(players.every((p) => p.isAlive), true);
    });

    test('player colors are assigned', () {
      final players = Player.createPlayers(3);
      for (final p in players) {
        expect(p.color, isNotNull);
      }
    });
  });

  group('GameState', () {
    test('initializes with empty grid', () {
      final state = GameState(rows: 9, cols: 6, playerCount: 2);
      for (int r = 0; r < 9; r++) {
        for (int c = 0; c < 6; c++) {
          expect(state.grid[r][c].isEmpty, true);
        }
      }
    });

    test('critical mass for corners is 2', () {
      final state = GameState(rows: 9, cols: 6, playerCount: 2);
      expect(state.criticalMass(0, 0), 2);
      expect(state.criticalMass(0, 5), 2);
      expect(state.criticalMass(8, 0), 2);
      expect(state.criticalMass(8, 5), 2);
    });

    test('critical mass for edges is 3', () {
      final state = GameState(rows: 9, cols: 6, playerCount: 2);
      expect(state.criticalMass(0, 3), 3);
      expect(state.criticalMass(4, 0), 3);
      expect(state.criticalMass(8, 3), 3);
      expect(state.criticalMass(4, 5), 3);
    });

    test('critical mass for center is 4', () {
      final state = GameState(rows: 9, cols: 6, playerCount: 2);
      expect(state.criticalMass(4, 3), 4);
    });

    test('can place on empty cell', () {
      final state = GameState(rows: 9, cols: 6, playerCount: 2);
      expect(state.canPlace(0, 0), true);
    });

    test('placing orb updates cell', () async {
      final state = GameState(rows: 9, cols: 6, playerCount: 2);
      await state.placeOrb(4, 3);
      expect(state.grid[4][3].orbs, 1);
      expect(state.grid[4][3].owner, 0);
    });

    test('turn advances after placing', () async {
      final state = GameState(rows: 9, cols: 6, playerCount: 2);
      expect(state.currentPlayerIndex, 0);
      await state.placeOrb(4, 3);
      expect(state.currentPlayerIndex, 1);
    });

    test('cannot place on opponent cell', () async {
      final state = GameState(rows: 9, cols: 6, playerCount: 2);
      await state.placeOrb(4, 3); // P1 places
      expect(state.canPlace(4, 3), false); // P2 can't place on P1's cell
    });

    test('can stack on own cell', () async {
      final state = GameState(rows: 9, cols: 6, playerCount: 2);
      await state.placeOrb(4, 3); // P1 places at center
      await state.placeOrb(0, 0); // P2 places elsewhere
      expect(state.canPlace(4, 3), true); // P1 can stack
    });

    test('reset restores initial state', () async {
      final state = GameState(rows: 9, cols: 6, playerCount: 2);
      await state.placeOrb(4, 3);
      state.reset();
      expect(state.turnCount, 0);
      expect(state.currentPlayerIndex, 0);
      expect(state.grid[4][3].isEmpty, true);
      expect(state.isGameOver, false);
    });

    test('explosion happens at critical mass', () async {
      final state = GameState(rows: 5, cols: 5, playerCount: 2);

      // Fill corner (0,0) to just below critical mass
      // Corner critical mass = 2, so place 1 orb, then on next turn place again
      await state.placeOrb(0, 0); // P1: 1 orb at (0,0)
      await state.placeOrb(2, 2); // P2: places elsewhere
      await state.placeOrb(0, 0); // P1: 2 orbs at (0,0) → explodes!

      // After explosion, (0,0) should have 0 orbs
      // Neighbors (0,1) and (1,0) should each have 1 orb owned by P1
      expect(state.grid[0][0].orbs, 0);
      expect(state.grid[0][1].orbs, 1);
      expect(state.grid[0][1].owner, 0);
      expect(state.grid[1][0].orbs, 1);
      expect(state.grid[1][0].owner, 0);
    });

    test('game state tracks alive players', () {
      final state = GameState(rows: 5, cols: 5, playerCount: 3);
      expect(state.alivePlayerCount, 3);
      state.players[1].isAlive = false;
      expect(state.alivePlayerCount, 2);
    });
  });
}
