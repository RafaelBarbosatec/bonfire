// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/collision/collision_util.dart';

export 'collision_data.dart';

/// Mixin responsible for adding stop the movement when happen collision
mixin BlockMovementCollision on Movement {
  bool _reflectionEnabled = false;
  bool _blockMovementCollisionEnabled = true;
  bool get blockMovementCollisionEnabled => _blockMovementCollisionEnabled;
  bool get blockMovementCollisionReflectionEnabled => _reflectionEnabled;

  void setupBlockMovementCollision({bool? enabled, bool? reflectionEnabled}) {
    _reflectionEnabled = reflectionEnabled ?? _reflectionEnabled;
    _blockMovementCollisionEnabled = enabled ?? _blockMovementCollisionEnabled;
  }

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
    Vector2 correction;
    double depth = 0;
    if (collisionData.depth > 0) {
      depth = collisionData.depth + 0.05;
    }
    correction = (-collisionData.normal * depth);
    superPosition = position + correction;

    onBlockMovementUpdateVelocity(other, collisionData);
  }

  void onBlockMovementUpdateVelocity(
    PositionComponent other,
    CollisionData collisionData,
  ) {
    if (_reflectionEnabled) {
      velocity -= getCollisionVelocityReflection(other, collisionData);
    } else {
      velocity -= Vector2(
        velocity.x * collisionData.normal.x.abs(),
        velocity.y * collisionData.normal.y.abs(),
      );
    }
  }

  Vector2 getCollisionVelocityReflection(
    PositionComponent other,
    CollisionData data,
  ) {
    return data.normal * velocity.dot(data.normal);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is Sensor || !_blockMovementCollisionEnabled) return;
    bool stopOtherMovement = true;
    bool isStatic = false;
    bool stopMovement = other is GameComponent
        ? onBlockMovement(intersectionPoints, other)
        : true;
    if (other is BlockMovementCollision) {
      stopOtherMovement = other.onBlockMovement(intersectionPoints, this);
      isStatic =
          _reflectionEnabled ? false : other.velocity.length > velocity.length;
    }

    if (!stopMovement || !stopOtherMovement) {
      return;
    }

    ShapeHitbox shape1 = shapeHitboxes.first;
    ShapeHitbox shape2 = other.children.query<ShapeHitbox>().first;

    (Vector2 normal, double depth)? colisionResult;

    if (_isPolygon(shape1)) {
      if (_isPolygon(shape2)) {
        colisionResult = _intersectPolygons(shape1, shape2, other);
      } else if (shape2 is CircleHitbox) {
        colisionResult = _intersectCirclePolygon(shape1, shape2, other);
      }
    } else if (shape1 is CircleHitbox) {
      if (_isPolygon(shape2)) {
        colisionResult = _intersectCirclePolygon(
          shape2,
          shape1,
          other,
          inverted: true,
        );
      } else if (shape2 is CircleHitbox) {
        colisionResult = _intersectCircles(shape1, shape2);
      }
    }

    if (colisionResult != null) {
      onBlockedMovement(
        other,
        CollisionData(
          normal: colisionResult.$1,
          depth: isStatic ? 0 : colisionResult.$2,
          intersectionPoints: intersectionPoints.toList(),
          direction: colisionResult.$1.toDirection(),
        ),
      );
    }
  }

  bool _isPolygon(ShapeHitbox shape) {
    return shape is RectangleHitbox || shape is PolygonHitbox;
  }

  (Vector2 normal, double depth) _intersectPolygons(
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

    return (normal, depth);
  }

  (Vector2 normal, double depth) _intersectCirclePolygon(
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

    return (normal, depth);
  }

  (Vector2 normal, double depth) _intersectCircles(
      CircleHitbox shapeA, CircleHitbox shapeB) {
    Vector2 normal = Vector2.zero();
    double depth = double.maxFinite;

    double distance = shapeA.absoluteCenter.distanceTo(shapeB.absoluteCenter);
    double radii = shapeA.radius + shapeB.radius;

    normal = (shapeB.absoluteCenter - shapeA.absoluteCenter).normalized();
    depth = radii - distance;

    return (normal, depth);
  }
}
