import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/collision_util.dart';

/// Mixin responsible for adding stop the movement when happen collision
mixin BlockMovementCollisionV2 on Movement {
  final _collisionUtil = CollisionUtil();

  bool onBlockMovement(
    Set<Vector2> intersectionPoints,
    GameComponent other,
  ) {
    return true;
  }

  void onBlockedMovement(
    PositionComponent other,
    Direction direction,
  ) {}

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is Sensor) return;
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

    if (_isPolygon(shape1)) {
      if (_isPolygon(shape2)) {
        _intersectPolygons(shape1, shape2, other);
      } else if (shape2 is CircleHitbox) {
        _intersectCirclePolygon(shape1, shape2, other);
      }
    } else if (shape1 is CircleHitbox) {
      if (_isPolygon(shape2)) {
        _intersectCirclePolygon(shape2, shape1, other);
      } else if (shape2 is CircleHitbox) {
        _intersectCircles(shape1, shape2);
      }
    }
  }

  bool _isPolygon(ShapeHitbox shape) {
    return shape is RectangleHitbox || shape is PolygonHitbox;
  }

  void _intersectPolygons(
    ShapeHitbox shapeA,
    ShapeHitbox shapeB,
    PositionComponent other,
  ) {
    Vector2 normal = Vector2.zero();
    double depth = double.maxFinite;

    List<Vector2> verticesA = _getPolygonVertices(shapeA);
    List<Vector2> verticesB = _getPolygonVertices(shapeB);

    for (int i = 0; i < verticesA.length; i++) {
      Vector2 va = verticesA[i];
      Vector2 vb = verticesA[(i + 1) % verticesA.length];

      Vector2 edge = vb - va;
      Vector2 axis = Vector2(-edge.y, edge.x);
      axis = axis.normalized();

      Vector2 pA = _projectVertices(verticesA, axis);
      Vector2 pB = _projectVertices(verticesB, axis);

      double axisDepth = min(pB.y - pA.x, pA.y - pB.x);

      if (axisDepth < depth) {
        depth = axisDepth;
        normal = axis;
      }
    }

    for (int i = 0; i < verticesB.length; i++) {
      Vector2 va = verticesB[i];
      Vector2 vb = verticesB[(i + 1) % verticesB.length];

      Vector2 edge = vb - va;
      Vector2 axis = Vector2(-edge.y, edge.x);
      axis = axis.normalized();

      Vector2 pA = _projectVertices(verticesA, axis);
      Vector2 pB = _projectVertices(verticesB, axis);
      if (pA.x >= pB.y || pB.x >= pA.y) {
        return;
      }

      double axisDepth = min(pB.y - pA.x, pA.y - pB.x);

      if (axisDepth < depth) {
        depth = axisDepth;
        normal = axis;
      }
    }

    Vector2 direction = shapeB.absoluteCenter - shapeA.absoluteCenter;

    if (direction.dot(normal) < 0) {
      normal = -normal;
    }

    superPosition = position + (-normal * depth / 2);

    // if (depth.abs() > 0.1 && !velocity.isZero()) {
    //   stopFromCollision(isX: normal.x.abs() > 0, isY: normal.y.abs() > 0);
    // }

    // other.position += (normal * depth / 2);
  }

  List<Vector2> _getPolygonVertices(ShapeHitbox shape) {
    Vector2 p = shape.absolutePosition;
    if (shape is PolygonHitbox) {
      return shape.vertices.map((element) {
        return element.translated(p.x, p.y);
      }).toList();
    } else if (shape is RectangleHitbox) {
      return shape.vertices.map((element) {
        return element.translated(p.x, p.y);
      }).toList();
    }
    return [];
  }

  Vector2 _projectVertices(List<Vector2> vertices, Vector2 axis) {
    double min = double.maxFinite;
    double max = double.minPositive;
    for (var v in vertices) {
      double proj = v.dot(axis);

      if (proj < min) {
        min = proj;
      }
      if (proj > max) {
        max = proj;
      }
    }
    return Vector2(min, max);
  }

  Vector2 _projectCircle(Vector2 center, double radius, Vector2 axis) {
    Vector2 direction = axis.normalized();
    Vector2 directionAndRadius = direction * radius;

    Vector2 p1 = center + directionAndRadius;
    Vector2 p2 = center - directionAndRadius;

    double min = p1.dot(axis);
    double max = p2.dot(axis);

    if (min > max) {
      // swap the min and max values.
      double t = min;
      min = max;
      max = t;
    }
    return Vector2(min, max);
  }

  void _intersectCirclePolygon(
    ShapeHitbox shapeA,
    CircleHitbox shapeB,
    PositionComponent other,
  ) {
    print('intersectCirclePolygon');
    Vector2 normal = Vector2.zero();
    double depth = double.maxFinite;
    Vector2 axis = Vector2.zero();
    double axisDepth = 0;

    List<Vector2> vertices = _getPolygonVertices(shapeA);

    for (int i = 0; i < vertices.length; i++) {
      Vector2 va = vertices[i];
      Vector2 vb = vertices[(i + 1) % vertices.length];

      Vector2 edge = vb - va;
      axis = Vector2(-edge.y, edge.x);
      axis = axis.normalized();

      Vector2 pA = _projectVertices(vertices, axis);
      Vector2 pB = _projectCircle(shapeB.absoluteCenter, shapeB.radius, axis);

      axisDepth = min(pB.y - pA.x, pA.y - pB.x);

      if (axisDepth < depth) {
        depth = axisDepth;
        normal = axis;
      }
    }

    int cpIndex = findClosesPointOnPolygon(shapeB.absoluteCenter, vertices);
    Vector2 cp = vertices[cpIndex];

    axis = cp - shapeB.absoluteCenter;
    axis = axis.normalized();

    Vector2 pA = _projectVertices(vertices, axis);
    Vector2 pB = _projectCircle(shapeB.absoluteCenter, shapeB.radius, axis);

    axisDepth = min(pB.y - pA.x, pA.y - pB.x);

    if (axisDepth < depth) {
      depth = axisDepth;
      normal = axis;
    }

    Vector2 direction = shapeA.absoluteCenter - shapeB.absoluteCenter;

    if (direction.dot(normal) < 0) {
      normal = -normal;
    }

    superPosition = position + (-normal * depth / 2);
  }

  int findClosesPointOnPolygon(Vector2 circleCenter, List<Vector2> vertices) {
    int result = -1;
    double minDistance = double.maxFinite;

    for (int i = 0; i < vertices.length; i++) {
      Vector2 v = vertices[i];
      double distance = v.distanceTo(circleCenter);

      if (distance < minDistance) {
        minDistance = distance;
        result = i;
      }
    }

    return result;
  }

  void _intersectCircles(CircleHitbox shapeA, CircleHitbox shapeB) {
    Vector2 normal = Vector2.zero();
    double depth = double.maxFinite;

    double distance = shapeA.absoluteCenter.distanceTo(shapeB.absoluteCenter);
    double radii = shapeA.radius + shapeB.radius;

    normal = (shapeB.absoluteCenter - shapeA.absoluteCenter).normalized();
    depth = radii - distance;

    superPosition = position + (-normal * depth / 2);
  }
}
