import 'package:flame/collisions.dart';

abstract class BonfireCollisionConfig {
  static BonfireCollisionConfig quadTree({
    double? minimumDistance,
    int maxObjects = 25,
    int maxLevels = 10,
  }) {
    return BonfireCollisionConfigQuadTree(
      maxLevels: maxLevels,
      maxObjects: maxObjects,
      minimumDistance: minimumDistance,
    );
  }

  static BonfireCollisionConfig dafault({
    Broadphase<ShapeHitbox>? customBroadPhase,
  }) {
    return BonfireCollisionConfigDefault(
      customBroadPhase: customBroadPhase,
    );
  }

  T when<T>({
    required T Function(BonfireCollisionConfigDefault) defaultCollision,
    required T Function(BonfireCollisionConfigQuadTree) quadTreeCollision,
  }) {
    return switch (this) {
      final BonfireCollisionConfigQuadTree c => quadTreeCollision(c),
      final BonfireCollisionConfigDefault c => defaultCollision(c),
      _ => throw UnimplementedError(),
    };
  }
}

class BonfireCollisionConfigQuadTree extends BonfireCollisionConfig {
  final double? minimumDistance;
  final int maxObjects;
  final int maxLevels;

  BonfireCollisionConfigQuadTree({
    this.minimumDistance,
    this.maxObjects = 25,
    this.maxLevels = 10,
  });
}

class BonfireCollisionConfigDefault extends BonfireCollisionConfig {
  final Broadphase<ShapeHitbox>? customBroadPhase;

  BonfireCollisionConfigDefault({
    this.customBroadPhase,
  });
}
