import 'package:flutter/material.dart';

class Player {
  final int id;
  final String name;
  final Color color;
  bool isAlive;

  Player({
    required this.id,
    required this.name,
    required this.color,
    this.isAlive = true,
  });

  static final List<Color> playerColors = [
    const Color(0xFFE53935), // Red
    const Color(0xFF1E88E5), // Blue
    const Color(0xFF43A047), // Green
    const Color(0xFFFFB300), // Amber
    const Color(0xFF8E24AA), // Purple
    const Color(0xFFFF6D00), // Deep Orange
  ];

  static List<Player> createPlayers(int count) {
    return List.generate(count, (i) {
      return Player(
        id: i,
        name: 'Player ${i + 1}',
        color: playerColors[i % playerColors.length],
      );
    });
  }
}
