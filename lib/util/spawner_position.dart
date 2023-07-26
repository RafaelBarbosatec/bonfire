import 'dart:math';

import 'package:bonfire/bonfire.dart';

typedef SpawnerPositionBuilder = GameComponent Function(Vector2 position);

class SpawnerPosition extends GameComponent {
  final ShapeHitbox area;
  // Interval in milliseconds
  final int interval;
  // If true only generated if visible in screen.
  final bool onlyVisible;
  // Builder that adds the component in the game.
  final SpawnerPositionBuilder builder;

  late Random _random;

  SpawnerPosition({
    required Vector2 position,
    required this.area,
    required this.interval,
    required this.builder,
    this.onlyVisible = true,
  }) {
    _random = Random();
    this.position = position;
    size = area.size;
  }

  @override
  void update(double dt) {
    if (checkInterval('SpawnPosition', interval, dt) &&
        !(onlyVisible && !isVisible)) {
      _spawn();
    }
    super.update(dt);
  }

  void _spawn() {
    Vector2 point = Vector2.zero();
    int count = 0;
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
