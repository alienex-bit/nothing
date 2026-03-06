import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class WaterSurface extends Component {
  final double surfaceY;
  final double width;

  WaterSurface({required this.surfaceY, this.width = 2000});

  @override
  void render(Canvas canvas) {
    // Air-Water interface visuals
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withOpacity(0.5),
          Colors.lightBlue.withOpacity(0.2),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(-width / 2, surfaceY, width, 20));

    canvas.drawRect(Rect.fromLTWH(-width / 2, surfaceY, width, 20), paint);

    // Surface line
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..strokeWidth = 0.2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(-width / 2, surfaceY),
      Offset(width / 2, surfaceY),
      linePaint,
    );
  }
}
