import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Seabed extends Component {
  final double depth;
  final int moundCount;

  Seabed({this.depth = 100, this.moundCount = 50});

  @override
  void render(Canvas canvas) {
    final random = math.Random(42); // Deterministic for consistency
    final paint = Paint()
      ..color = const Color(0xFFC2B280)
          .withOpacity(0.8) // More opaque
      ..style = PaintingStyle.fill;

    // Draw procedural sand mounds
    for (var i = 0; i < moundCount; i++) {
      final xPos = (random.nextDouble() - 0.5) * 1000;
      final width = 20.0 + random.nextDouble() * 60.0;
      final height = 10.0 + random.nextDouble() * 25.0;

      final rect = Rect.fromCenter(
        center: Offset(xPos, depth + height / 2 - 2),
        width: width,
        height: height,
      );

      canvas.drawOval(rect, paint);
    }

    // Thick base floor with gradient
    final floorRect = Rect.fromLTWH(-500, depth, 1000, 500);
    final floorPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFC2B280),
          const Color(0xFF8B4513).withOpacity(0.8),
        ],
      ).createShader(floorRect);

    canvas.drawRect(floorRect, floorPaint);
  }
}
