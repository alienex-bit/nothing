import 'dart:math' as math;
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'food_element.dart';

class Protocell extends BodyComponent with ContactCallbacks {
  static const double minRadius = 0.8;
  static const double maxRadius = 2.4;

  final Vector2 position;
  double radius = minRadius;
  double growthPercentage = 0.0;

  double _time = 0;
  bool _needsGrowthUpdate = false;

  Protocell({required this.position});

  @override
  Body createBody() {
    final shape = CircleShape()..radius = radius;
    final fixtureDef = FixtureDef(
      shape,
      userData: this,
      restitution: 0.8,
      friction: 0.2,
    );

    final bodyDef = BodyDef(
      position: position,
      type: BodyType.dynamic,
      linearDamping: 4.0, // Increased for fluid resistance
    );

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    print('Protocell loaded');
  }

  void moveBy(Vector2 delta) {
    body.applyLinearImpulse(delta * 1.5); // Increased for better feel
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;

    // Clamp velocity to ensure camera can keep up and movement feels organic
    final velocity = body.linearVelocity;
    if (velocity.length > 15.0) {
      body.linearVelocity = velocity.normalized() * 15.0;
    }

    if (_needsGrowthUpdate) {
      _updateFixtures();
      _needsGrowthUpdate = false;
    }
  }

  @override
  void render(Canvas canvas) {
    // Organic pulsation scale
    final pulse = 1.0 + 0.05 * math.sin(_time * 2.5);

    // Membrane Border (thick prominent edge to see throbbing)
    final borderPaint = Paint()
      ..color = Colors.cyan.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.08;
    canvas.drawCircle(Offset.zero, radius * pulse * 1.05, borderPaint);

    // Membrane Fill (near invisible to remove white haze)
    final membranePaint = Paint()
      ..color = Colors.cyan.withOpacity(0.02)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset.zero, radius * pulse * 1.05, membranePaint);

    // Main Cell Body (near invisible)
    final bodyPaint = Paint()
      ..color = Colors.cyan.withOpacity(0.05)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset.zero, radius * pulse, bodyPaint);

    // Biological nucleus (Highly Visible Red dot)
    final nucleusPaint = Paint()
      ..color =
          const Color(0xFFFF0000) // Pure Red
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset.zero, radius * 0.3, nucleusPaint);
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (other is FoodElement && growthPercentage < 100) {
      other.removeFromParent();

      // Each food gives 5% growth
      growthPercentage = (growthPercentage + 5.0).clamp(0, 100);

      // Map growth percentage to radius
      radius = minRadius + (maxRadius - minRadius) * (growthPercentage / 100);

      _needsGrowthUpdate = true;
    }
  }

  void _updateFixtures() {
    // Update body fixture to reflect new size
    if (body.fixtures.isNotEmpty) {
      final oldFixture = body.fixtures.first;
      body.destroyFixture(oldFixture);
    }

    final shape = CircleShape()..radius = radius;
    final fixtureDef = FixtureDef(
      shape,
      userData: this,
      restitution: 0.8,
      friction: 0.2,
    );
    body.createFixture(fixtureDef);
  }
}
