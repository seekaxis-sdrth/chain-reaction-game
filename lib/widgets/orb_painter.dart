import 'dart:math';
import 'package:flutter/material.dart';

class OrbPainter extends CustomPainter {
  final int orbCount;
  final Color color;
  final double animationValue;

  OrbPainter({
    required this.orbCount,
    required this.color,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (orbCount == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = min(size.width, size.height) / 2;
    final orbRadius = maxRadius * _orbRadiusFactor;

    final paint = Paint()..style = PaintingStyle.fill;

    final highlightPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withValues(alpha: 0.5);

    final positions = _getOrbPositions(orbCount, center, maxRadius * 0.35);

    for (int i = 0; i < orbCount && i < positions.length; i++) {
      final wobble = sin(animationValue * 2 * pi + i * pi / 2) * 1.5;
      final pos = Offset(positions[i].dx + wobble, positions[i].dy + wobble);

      paint.shader = RadialGradient(
        center: const Alignment(-0.3, -0.3),
        colors: [
          Color.lerp(color, Colors.white, 0.4)!,
          color,
          Color.lerp(color, Colors.black, 0.3)!,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: pos, radius: orbRadius));

      canvas.drawCircle(pos, orbRadius, paint);

      canvas.drawCircle(
        Offset(pos.dx - orbRadius * 0.25, pos.dy - orbRadius * 0.25),
        orbRadius * 0.2,
        highlightPaint,
      );
    }
  }

  double get _orbRadiusFactor {
    switch (orbCount) {
      case 1:
        return 0.3;
      case 2:
        return 0.22;
      case 3:
        return 0.19;
      default:
        return 0.16;
    }
  }

  List<Offset> _getOrbPositions(int count, Offset center, double spread) {
    switch (count) {
      case 1:
        return [center];
      case 2:
        return [
          Offset(center.dx - spread, center.dy),
          Offset(center.dx + spread, center.dy),
        ];
      case 3:
        return [
          Offset(center.dx, center.dy - spread * 0.8),
          Offset(center.dx - spread * 0.7, center.dy + spread * 0.5),
          Offset(center.dx + spread * 0.7, center.dy + spread * 0.5),
        ];
      default:
        return List.generate(count, (i) {
          final angle = (2 * pi * i / count) - pi / 2;
          return Offset(
            center.dx + spread * cos(angle),
            center.dy + spread * sin(angle),
          );
        });
    }
  }

  @override
  bool shouldRepaint(OrbPainter oldDelegate) =>
      oldDelegate.orbCount != orbCount ||
      oldDelegate.color != color ||
      oldDelegate.animationValue != animationValue;
}
