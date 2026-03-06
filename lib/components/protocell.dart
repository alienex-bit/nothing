import 'dart:math' as math;
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'food_element.dart';

class Protocell extends BodyComponent with ContactCallbacks {
  static const double minRadius = 0.4;
  static const double maxRadius = 1.2;

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
    body.applyLinearImpulse(
      delta * 0.4,
    ); // Reduced impulse for microscopic control
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

    // Membrane (semi-transparent outer layer)
    final membranePaint = Paint()
      ..color = Colors.cyan.withOpacity(0.15)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset.zero, radius * pulse * 1.12, membranePaint);

    // Main Cell Body
    final bodyPaint = Paint()
      ..color = Colors.cyan.withOpacity(0.5)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset.zero, radius * pulse, bodyPaint);

    // Small biological nucleus
    final nucleusPaint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset.zero, radius * 0.15, nucleusPaint);
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
