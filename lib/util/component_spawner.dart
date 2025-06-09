import 'dart:math';

import 'package:bonfire/bonfire.dart';

typedef SpawnerPositionBuilder = GameComponent Function(Vector2 position);

/// Componente used to spaw other components
class ComponentSpawner extends GameComponent {
  // Area that will spaw the components
  final ShapeHitbox area;
  // Interval in milliseconds
  final int interval;
  // If true only generated if visible in screen.
  final bool onlyVisible;
  // Builder that adds the component in the game.
  final SpawnerPositionBuilder builder;

  final bool Function(BonfireGameInterface game)? spawnCondition;

  late Random _random;

  ComponentSpawner({
    required Vector2 position,
    required this.area,
    required this.interval,
    required this.builder,
    this.spawnCondition,
    this.onlyVisible = true,
  }) {
    _random = Random();
    this.position = position;
    size = area.size;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (checkInterval('SpawnPosition', interval, dt)) {
      var enabled = true;
      if (onlyVisible) {
        enabled = isVisible;
      }
      if (spawnCondition?.call(gameRef) ?? true && enabled) {
        _spawn();
      }
    }
  }

  void _spawn() {
    var point = Vector2.zero();
    var count = 0;
    do {
      point = Vector2(
        size.x * _random.nextDouble(),
        size.y * _random.nextDouble(),
      );

      count++;
    } while (!area.containsLocalPoint(point) && count < 10);
    if (count < 10) {
      point.add(absolutePosition);
      gameRef.add(builder(point));
    }
  }
}
