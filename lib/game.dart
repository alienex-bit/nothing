import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'components/protocell.dart';
import 'components/food_element.dart';
import 'components/background_debris.dart';
import 'dart:math';

class NothingGame extends Forge2DGame with DragCallbacks {
  NothingGame() : super(gravity: Vector2.zero(), zoom: 20);

  late final Protocell protocell;
  late final TextComponent growthHud;

  @override
  Color backgroundColor() => const Color(0xFF001219);

  @override
  bool get debugMode => true;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Center the camera on the world origin initially
    camera.viewfinder.anchor = Anchor.center;
    camera.viewfinder.zoom = 20;

    // Add the Protocell
    protocell = Protocell(position: Vector2.zero());
    await world.add(protocell);

    // Follow the Protocell
    camera.follow(protocell);

    // Add HUD
    growthHud = TextComponent(
      text: 'Growth: 0%',
      anchor: Anchor.topCenter,
      position: Vector2(camera.viewport.size.x / 2, 50),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontFamily: 'Courier',
        ),
      ),
    );
    camera.viewport.add(growthHud);

    // Add some initial food element
    _spawnFood();

    // Add ocean atmosphere
    _spawnBackgroundDebris();
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Update HUD text
    growthHud.text = 'Growth: ${protocell.growthPercentage.toInt()}%';

    // Check for evolution
    if (protocell.growthPercentage >= 100) {
      // Future stage transition logic here
    }
  }

  void _spawnBackgroundDebris() {
    final random = Random();
    for (var i = 0; i < 300; i++) {
      add(
        BackgroundDebris(
          position: Vector2(
            (random.nextDouble() - 0.5) * 1000, // Much wider field
            (random.nextDouble() - 0.5) * 1000,
          ),
          size: 0.1 + random.nextDouble() * 0.4,
          color: Colors.white.withOpacity(0.1 + random.nextDouble() * 0.3),
          parallaxFactor: 0.2 + random.nextDouble() * 0.6,
        ),
      );
    }
  }

  void _spawnFood() {
    final random = Random();
    for (var i = 0; i < 100; i++) {
      add(
        FoodElement(
          position: Vector2(
            (random.nextDouble() - 0.5) * 200,
            (random.nextDouble() - 0.5) * 200,
          ),
        ),
      );
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    // Scale delta by zoom to keep movement consistent with visual distance
    final scaledDelta =
        Vector2(event.localDelta.x, event.localDelta.y) /
        camera.viewfinder.zoom;
    protocell.moveBy(scaledDelta * 5.0);
  }
}
