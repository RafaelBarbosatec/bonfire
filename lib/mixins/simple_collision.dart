import 'dart:math';

import 'package:bonfire/bonfire.dart';

/// Simplified collision system for SimpleMovement
///
/// This mixin adds collision detection and movement blocking to components
/// using SimpleMovement. It's much simpler than the original BlockMovementCollision
/// but covers the most common collision scenarios.
mixin SimpleCollision on SimpleMovement {
  BodyType _bodyType = BodyType.dynamic;
  bool _collisionEnabled = true;
  CollisionData? _lastCollisionData;

  // Public getters
  bool get collisionEnabled => _collisionEnabled;
  CollisionData? get lastCollisionData => _lastCollisionData;
  BodyType get bodyType => _bodyType;

  /// Setup collision behavior
  void setupCollision({
    bool? enabled,
    BodyType? bodyType,
  }) {
    _collisionEnabled = enabled ?? _collisionEnabled;
    _bodyType = bodyType ?? _bodyType;
  }

  /// Override this to customize collision behavior
  /// Return false to ignore this collision
  bool shouldBlockMovement(
    Set<Vector2> intersectionPoints,
    GameComponent other,
  ) {
    return true;
  }

  /// Called when movement is blocked by collision
  void onMovementBlocked(
    PositionComponent other,
    CollisionData collisionData,
  ) {
    _lastCollisionData = collisionData;

    // Only dynamic bodies get moved
    if (_bodyType.isDynamic) {
      _correctPosition(collisionData);
      _adjustVelocity(collisionData);
    }
  }

  /// Correct position to resolve collision penetration
  void _correctPosition(CollisionData collisionData) {
    var depth = collisionData.depth.abs();
    if (depth > 0) {
      depth += 0.05; // Small margin to prevent sticking
    }

    final correction = -collisionData.normal * depth;
    position += correction;
  }

  /// Adjust velocity to stop movement into collision
  void _adjustVelocity(CollisionData collisionData) {
    if (_bodyType.isStatic) return;

    // Remove velocity component that's moving into the collision
    final velocityIntoCollision =
        collisionData.normal * velocity.dot(collisionData.normal);

    if (velocityIntoCollision.dot(collisionData.normal) > 0) {
      velocity -= velocityIntoCollision;
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    // Skip if collision disabled or other is a sensor
    if (!_collisionEnabled || other is Sensor) {
      super.onCollision(intersectionPoints, other);
      return;
    }

    // Check if we should block this collision
    final shouldBlock = other is GameComponent
        ? shouldBlockMovement(intersectionPoints, other)
        : true;

    if (!shouldBlock) {
      super.onCollision(intersectionPoints, other);
      return;
    }

    // Calculate collision data
    final collisionData = _calculateCollisionData(intersectionPoints, other);
    if (collisionData != null) {
      onMovementBlocked(other, collisionData);
    }

    super.onCollision(intersectionPoints, other);
  }

  /// Calculate collision normal and depth (simplified version)
  CollisionData? _calculateCollisionData(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    if (intersectionPoints.isEmpty) return null;

    final myHitbox = _getMainHitbox(shapeHitboxes, intersectionPoints);
    final otherHitbox = _getMainHitbox(
      other.children.query<ShapeHitbox>(),
      intersectionPoints,
    );

    if (myHitbox == null || otherHitbox == null) return null;

    // Simple collision resolution based on centers
    final myCenter = myHitbox.absoluteCenter;
    final otherCenter = otherHitbox.absoluteCenter;
    final direction = myCenter - otherCenter;

    if (direction.isZero()) {
      // Fallback if centers are the same
      return CollisionData(
        normal: Vector2(1, 0), // Default to right
        depth: 1.0,
        intersectionPoints: intersectionPoints.toList(),
        direction: Direction.right,
      );
    }

    final normal = direction.normalized();
    final depth = _calculateCollisionDepth(myHitbox, otherHitbox);

    return CollisionData(
      normal: normal,
      depth: depth,
      intersectionPoints: intersectionPoints.toList(),
      direction: normal.toDirection(),
    );
  }

  /// Calculate collision depth (simplified)
  double _calculateCollisionDepth(ShapeHitbox hitbox1, ShapeHitbox hitbox2) {
    // Simple depth calculation based on distance and sizes
    final distance = hitbox1.absoluteCenter.distanceTo(hitbox2.absoluteCenter);

    if (hitbox1 is CircleHitbox && hitbox2 is CircleHitbox) {
      final combinedRadius = hitbox1.radius + hitbox2.radius;
      return max(0, combinedRadius - distance);
    }

    // For rectangles/polygons, use a simplified approach
    final avgSize1 = _getAverageSize(hitbox1);
    final avgSize2 = _getAverageSize(hitbox2);
    final combinedSize = (avgSize1 + avgSize2) / 2;

    return max(0, combinedSize - distance);
  }

  /// Get average size of a hitbox
  double _getAverageSize(ShapeHitbox hitbox) {
    if (hitbox is CircleHitbox) {
      return hitbox.radius;
    } else if (hitbox is RectangleHitbox) {
      return (hitbox.size.x + hitbox.size.y) / 4; // Quarter of perimeter
    }
    // Fallback for other shapes
    return 10.0;
  }

  /// Get the main hitbox for collision (prefer closest to intersection)
  ShapeHitbox? _getMainHitbox(
    Iterable<ShapeHitbox> hitboxes,
    Set<Vector2> intersectionPoints,
  ) {
    if (hitboxes.isEmpty || intersectionPoints.isEmpty) return null;
    if (hitboxes.length == 1) return hitboxes.first;

    // Find hitbox closest to intersection points
    ShapeHitbox? closest;
    var closestDistance = double.infinity;

    for (final hitbox in hitboxes) {
      for (final point in intersectionPoints) {
        final distance = hitbox.absoluteCenter.distanceTo(point);
        if (distance < closestDistance) {
          closestDistance = distance;
          closest = hitbox;
        }
      }
    }

    return closest;
  }
}
