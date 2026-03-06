import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

class FoodElement extends BodyComponent {
  final Vector2 position;
  final double radius = 0.2;

  FoodElement({required this.position});

  @override
  Body createBody() {
    final shape = CircleShape()..radius = radius;
    final fixtureDef = FixtureDef(
      shape,
      userData: this,
      isSensor:
          true, // Sensors don't cause physical collision but trigger contact
    );

    final bodyDef = BodyDef(position: position, type: BodyType.static);

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.greenAccent.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset.zero, radius, paint);
  }
}
