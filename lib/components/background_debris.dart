import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

class BackgroundDebris extends Component with HasGameReference<Forge2DGame> {
  final Vector2 position;
  final double size;
  final Color color;
  final double? _parallaxFactor; // Nullable for hot-reload safety
  double get parallaxFactor => _parallaxFactor ?? 0.5;

  final double _randomSeed = math.Random().nextDouble() * math.pi * 2;
  double _time = 0;

  BackgroundDebris({
    required this.position,
    required this.size,
    required this.color,
    double parallaxFactor = 0.5,
  }) : _parallaxFactor = parallaxFactor;

  @override
  void update(double dt) {
    _time += dt;
  }

  @override
  void render(Canvas canvas) {
    // Parallax adjustment: move slightly with the camera to feel distant
    final camPos = game.camera.viewfinder.position;
    final parallaxOffset = camPos * (1 - parallaxFactor);

    // Subtle drift/wobble effect
    final xWobble = math.sin(_time * 0.5 + _randomSeed) * 2.0;
    final yWobble = math.cos(_time * 0.3 + _randomSeed) * 2.0;

    final paint = Paint()
      ..color = color.withOpacity((color.opacity * 1.5).clamp(0, 0.4));
    canvas.drawCircle(
      Offset(
        position.x - parallaxOffset.x + xWobble,
        position.y - parallaxOffset.y + yWobble,
      ),
      size * 1.5,
      paint,
    );
  }
}
