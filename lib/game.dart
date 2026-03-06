import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/experimental.dart' as exp;
import 'package:flame_forge2d/flame_forge2d.dart';
import 'components/protocell.dart';
import 'components/food_element.dart';
import 'components/background_debris.dart';
import 'components/water_surface.dart';
import 'components/seabed.dart';
import 'dart:math' as math;

class NothingGame extends Forge2DGame with DragCallbacks {
  NothingGame() : super(gravity: Vector2.zero(), zoom: 20);

  // World constants (Tightened for better gameplay feel)
  static const double worldWidth = 400;
  static const double worldDepth = 200;
  static const double worldSurface = -100;

  late final Protocell protocell;
  late final TextComponent growthHud;

  @override
  Color backgroundColor() => const Color(0xFF001D29); // Slightly lighter, more vibrant teal

  @override
  bool get debugMode => false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Center the camera on the world origin initially
    camera.viewfinder.anchor = Anchor.center;
    camera.viewfinder.zoom = 20;

    // Constrain camera viewport to the ocean world
    camera.setBounds(
      exp.Rectangle.fromLTRB(
        -worldWidth / 2,
        worldSurface,
        worldWidth / 2,
        worldDepth,
      ),
    );

    // Boundary Wall (ChainShape loop)
    _addWorldBoundaries();

    // Add depth gradient background
    await world.add(
      DepthGradient(
        top: worldSurface,
        bottom: worldDepth,
        width: worldWidth * 2,
      ),
    );

    // Add the Protocell
    protocell = Protocell(position: Vector2.zero());
    await world.add(protocell);

    // Follow the Protocell and set bounds
    camera.follow(protocell);
    camera.setBounds(
      exp.Rectangle.fromLTRB(
        -worldWidth / 2,
        worldSurface,
        worldWidth / 2,
        worldDepth,
      ),
    );

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

    // Add Seabed at the bottom
    await world.add(Seabed(depth: worldDepth, moundCount: 150)..priority = 1);

    // Add Water Surface at the top
    await world.add(
      WaterSurface(surfaceY: worldSurface, width: worldWidth * 2)..priority = 1,
    );
  }

  void _addWorldBoundaries() {
    // Create actual physical walls that the Protocell will collide with
    final floorY = worldDepth;
    final ceilingY = worldSurface;
    final leftX = -worldWidth / 2;
    final rightX = worldWidth / 2;

    // Bottom Wall (Seabed Floor)
    world.createBody(BodyDef(type: BodyType.static))..createFixture(
      FixtureDef(
        EdgeShape()..set(Vector2(leftX, floorY), Vector2(rightX, floorY)),
      ),
    );

    // Top Wall (Water Surface)
    world.createBody(BodyDef(type: BodyType.static))..createFixture(
      FixtureDef(
        EdgeShape()..set(Vector2(leftX, ceilingY), Vector2(rightX, ceilingY)),
      ),
    );

    // Left Wall
    world.createBody(BodyDef(type: BodyType.static))..createFixture(
      FixtureDef(
        EdgeShape()..set(Vector2(leftX, ceilingY), Vector2(leftX, floorY)),
      ),
    );

    // Right Wall
    world.createBody(BodyDef(type: BodyType.static))..createFixture(
      FixtureDef(
        EdgeShape()..set(Vector2(rightX, ceilingY), Vector2(rightX, floorY)),
      ),
    );
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
    final random = math.Random();
    for (var i = 0; i < 300; i++) {
      world.add(
        BackgroundDebris(
          position: Vector2(
            (random.nextDouble() - 0.5) * 1200,
            (random.nextDouble() - 0.5) * 800,
          ),
          size: 0.1 + random.nextDouble() * 0.4,
          color: Colors.white.withOpacity(0.2 + random.nextDouble() * 0.4),
          parallaxFactor: 0.2 + random.nextDouble() * 0.6,
        ),
      );
    }
  }

  void _spawnFood() {
    final random = math.Random();
    for (var i = 0; i < 100; i++) {
      world.add(
        FoodElement(
          position: Vector2(
            (random.nextDouble() - 0.5) * 500,
            (random.nextDouble() - 0.5) * 400,
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
    protocell.moveBy(scaledDelta * 20.0); // Increased for better feel
  }
}

class DepthGradient extends Component {
  final double top;
  final double bottom;
  final double width;

  DepthGradient({required this.top, required this.bottom, required this.width})
    : super(priority: -100);

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTRB(-width / 2, top, width / 2, bottom);
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF003D5B), // Lighter surface
          const Color(0xFF001D29), // Medium
          const Color(0xFF000814), // Dark abyss
        ],
      ).createShader(rect);

    canvas.drawRect(rect, paint);
  }
}
