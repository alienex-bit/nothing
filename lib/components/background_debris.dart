import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import '../game.dart';

class BackgroundDebris extends Component with HasGameReference<NothingGame> {
  final Vector2 position;
  final double size;
  final Color color;
  final double parallaxFactor;

  final double _randomSeed = math.Random().nextDouble() * math.pi * 2;
  double _time = 0;

  BackgroundDebris({
    required this.position,
    required this.size,
    required this.color,
    this.parallaxFactor = 0.5,
  }) : super(priority: -50);

  @override
  void update(double dt) {
    _time += dt;
  }

  @override
  void render(Canvas canvas) {
    // Correct Parallax: DrawPos = position + camPos * (1 - factor)
    final camPos = game.camera.viewfinder.position;
    final parallaxOffset = camPos * (1 - parallaxFactor);

    final xWobble = math.sin(_time * 0.5 + _randomSeed) * 2.0;
    final yWobble = math.cos(_time * 0.3 + _randomSeed) * 2.0;

    final paint = Paint()
      ..color = color.withOpacity((color.opacity * 2.0).clamp(0, 0.7));

    canvas.drawCircle(
      Offset(
        position.x + parallaxOffset.x + xWobble,
        position.y + parallaxOffset.y + yWobble,
      ),
      size * 1.5,
      paint,
    );
  }
}
