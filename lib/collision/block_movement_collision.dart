// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/collision/collision_util.dart';

/// Mixin responsible for adding stop the movement when happen collision
mixin BlockMovementCollision on Movement {
  bool onBlockMovement(
    Set<Vector2> intersectionPoints,
    GameComponent other,
  ) {
    return true;
  }

  void onBlockedMovement(
    PositionComponent other,
    CollisionData collisionData,
  ) {
    superPosition =
        position + (-collisionData.normal * (collisionData.depth + 0.05));
    if (collisionData.depth.abs() > 0.1 && !velocity.isZero()) {
      stopFromCollision(
        isX: collisionData.normal.x.abs() > 0.1,
        isY: collisionData.normal.y.abs() > 0.1,
      );
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is Sensor) return;
    if (isStopped()) return;
    bool stopMovement = other is GameComponent
        ? onBlockMovement(intersectionPoints, other)
        : true;
    bool stopOtherMovement = other is BlockMovementCollision
        ? other.onBlockMovement(intersectionPoints, this)
        : true;
    if (!stopMovement || !stopOtherMovement) {
      return;
    }

    ShapeHitbox shape1 = shapeHitboxes.first;
    ShapeHitbox shape2 = other.children.query<ShapeHitbox>().first;

    CollisionData? collisionData;

    if (_isPolygon(shape1)) {
      if (_isPolygon(shape2)) {
        collisionData = _intersectPolygons(shape1, shape2, other);
      } else if (shape2 is CircleHitbox) {
        collisionData = _intersectCirclePolygon(shape1, shape2, other);
      }
    } else if (shape1 is CircleHitbox) {
      if (_isPolygon(shape2)) {
        collisionData = _intersectCirclePolygon(
          shape2,
          shape1,
          other,
          inverted: true,
        );
      } else if (shape2 is CircleHitbox) {
        collisionData = _intersectCircles(shape1, shape2);
      }
    }

    if (collisionData != null) {
      onBlockedMovement(
        other,
        collisionData.copyWith(
          intersectionPoints: intersectionPoints.toList(),
          direction: collisionData.normal.toDirection(),
        ),
      );
    }
  }

  bool _isPolygon(ShapeHitbox shape) {
    return shape is RectangleHitbox || shape is PolygonHitbox;
  }

  CollisionData _intersectPolygons(
    ShapeHitbox shapeA,
    ShapeHitbox shapeB,
    PositionComponent other,
  ) {
    Vector2 normal = Vector2.zero();
    double depth = double.maxFinite;

    List<Vector2> verticesA = CollisionUtil.getPolygonVertices(shapeA);
    List<Vector2> verticesB = CollisionUtil.getPolygonVertices(shapeB);

    var normalAndDepthA = CollisionUtil.getNormalAndDepth(
      verticesA,
      verticesB,
    );

    if (normalAndDepthA.second < depth) {
      depth = normalAndDepthA.second;
      normal = normalAndDepthA.first;
    }
    var normalAndDepthB = CollisionUtil.getNormalAndDepth(
      verticesB,
      verticesA,
      insverted: true,
    );

    if (normalAndDepthB.second < depth) {
      depth = normalAndDepthB.second;
      normal = normalAndDepthB.first;
    }

    Vector2 direction = shapeB.absoluteCenter - shapeA.absoluteCenter;

    if (direction.dot(normal) < 0) {
      normal = -normal;
    }

    return CollisionData(
      normal: normal,
      depth: depth,
    );
  }

  CollisionData _intersectCirclePolygon(
    ShapeHitbox shapeA,
    CircleHitbox shapeB,
    PositionComponent other, {
    bool inverted = false,
  }) {
    Vector2 normal = Vector2.zero();
    double depth = double.maxFinite;
    Vector2 axis = Vector2.zero();
    double axisDepth = 0;

    List<Vector2> vertices = CollisionUtil.getPolygonVertices(shapeA);

    for (int i = 0; i < vertices.length; i++) {
      Vector2 va = vertices[i];
      Vector2 vb = vertices[(i + 1) % vertices.length];

      Vector2 edge = vb - va;
      axis = Vector2(-edge.y, edge.x);
      axis = axis.normalized();

      Vector2 pA = CollisionUtil.projectVertices(vertices, axis);
      Vector2 pB = CollisionUtil.projectCircle(
        shapeB.absoluteCenter,
        shapeB.radius,
        axis,
      );

      axisDepth = min(pB.y - pA.x, pA.y - pB.x);

      if (axisDepth < depth) {
        depth = axisDepth;
        normal = axis;
      }
    }

    int cpIndex = CollisionUtil.findClosesPointOnPolygon(
      shapeB.absoluteCenter,
      vertices,
    );
    Vector2 cp = vertices[cpIndex];

    axis = cp - shapeB.absoluteCenter;
    axis = axis.normalized();

    Vector2 pA = CollisionUtil.projectVertices(vertices, axis);
    Vector2 pB = CollisionUtil.projectCircle(
      shapeB.absoluteCenter,
      shapeB.radius,
      axis,
    );

    axisDepth = min(pB.y - pA.x, pA.y - pB.x);

    if (axisDepth < depth) {
      depth = axisDepth;
      normal = axis;
    }

    Vector2 direction = inverted
        ? shapeA.absoluteCenter - shapeB.absoluteCenter
        : shapeB.absoluteCenter - shapeA.absoluteCenter;

    if (direction.dot(normal) < 0) {
      normal = -normal;
    }

    return CollisionData(
      normal: normal,
      depth: depth,
    );
  }

  CollisionData _intersectCircles(CircleHitbox shapeA, CircleHitbox shapeB) {
    Vector2 normal = Vector2.zero();
    double depth = double.maxFinite;

    double distance = shapeA.absoluteCenter.distanceTo(shapeB.absoluteCenter);
    double radii = shapeA.radius + shapeB.radius;

    normal = (shapeB.absoluteCenter - shapeA.absoluteCenter).normalized();
    depth = radii - distance;

    return CollisionData(
      normal: normal,
      depth: depth,
    );
  }
}

class CollisionData {
  final Vector2 normal;
  final double depth;
  final List<Vector2> intersectionPoints;
  final Direction direction;

  CollisionData({
    required this.normal,
    required this.depth,
    this.direction = Direction.left,
    this.intersectionPoints = const [],
  });

  CollisionData copyWith({
    Vector2? normal,
    double? depth,
    Direction? direction,
    List<Vector2>? intersectionPoints,
  }) {
    return CollisionData(
      normal: normal ?? this.normal,
      depth: depth ?? this.depth,
      direction: direction ?? this.direction,
      intersectionPoints: intersectionPoints ?? this.intersectionPoints,
    );
  }
}
