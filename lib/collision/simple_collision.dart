// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/collision/collision_util.dart';
export 'body_type.dart';
export 'collision_data.dart';

/// Mixin responsible for adding stop the movement when happen collision
mixin SimpleCollision on Movement {
  BodyType bodyType = BodyType.dynamic;
  bool _blockMovementCollisionEnabled = true;
  bool get blockMovementCollisionEnabled => _blockMovementCollisionEnabled;
  final Map<SimpleCollision, CollisionData> _collisionsResolution = {};
  CollisionData? _lastCollisionData;
  CollisionData? get lastCollisionData => _lastCollisionData;

  void setupCollision({bool? enabled, BodyType? bodyType}) {
    this.bodyType = bodyType ?? this.bodyType;
    _blockMovementCollisionEnabled = enabled ?? _blockMovementCollisionEnabled;
  }

  void setCollisionResolution(
    SimpleCollision other,
    CollisionData data,
  ) {
    _collisionsResolution[other] = data;
  }

  bool onBlockMovement(
    Set<Vector2> intersectionPoints,
    GameComponent other,
  ) {
    return true;
  }

  void onMovementBlocked(
    PositionComponent other,
    CollisionData collisionData,
  ) {
    _lastCollisionData = collisionData;

    if (bodyType.isDynamic) {
      Vector2 correction;
      var depth = collisionData.depth.abs();
      if (depth > 0) {
        depth += 0.08;
      }

      correction = -collisionData.normal * depth;
      if ((other is SimpleCollision) && other.bodyType.isDynamic) {
        correction = -collisionData.normal * depth / 2;
      }

      position += correction;
    }
    velocity -= getVelocityReflection(other, collisionData);
  }

  Vector2 getVelocityReflection(
    PositionComponent other,
    CollisionData data,
  ) {
    if (bodyType.isStatic) {
      return velocity;
    }
    return data.normal * velocity.dot(data.normal);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Sensor || !_blockMovementCollisionEnabled) {
      super.onCollision(intersectionPoints, other);
      return;
    }
    var stopOtherMovement = true;
    final stopMovement = other is GameComponent
        ? onBlockMovement(intersectionPoints, other)
        : true;
    if (other is SimpleCollision) {
      stopOtherMovement = other.onBlockMovement(
        intersectionPoints,
        this,
      );
    }

    if (!stopMovement || !stopOtherMovement) {
      super.onCollision(intersectionPoints, other);
      return;
    }

    if (_collisionsResolution.containsKey(other)) {
      onMovementBlocked(
        other,
        _collisionsResolution[other]!,
      );
      _collisionsResolution.remove(other);
      super.onCollision(intersectionPoints, other);
      return;
    }

    final shape1 = _getCollisionShapeHitbox(
      shapeHitboxes,
      intersectionPoints,
    );
    final shape2 = _getCollisionShapeHitbox(
      other.children.query<ShapeHitbox>(),
      intersectionPoints,
    );

    if (shape1 == null || shape2 == null) {
      super.onCollision(intersectionPoints, other);
      return;
    }

    ({Vector2 normal, double depth})? colisionResult;

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
      final data = CollisionData(
        normal: colisionResult.normal,
        depth: colisionResult.depth,
        intersectionPoints: intersectionPoints.toList(),
        direction: colisionResult.normal.toDirection(),
      );
      onMovementBlocked(other, data);
      if (other is SimpleCollision) {
        other.setCollisionResolution(this, data.inverted());
      }
    }
    super.onCollision(intersectionPoints, other);
  }

  bool _isPolygon(ShapeHitbox shape) {
    return shape is RectangleHitbox || shape is PolygonHitbox;
  }

  ({Vector2 normal, double depth}) _intersectPolygons(
    ShapeHitbox shapeA,
    ShapeHitbox shapeB,
    PositionComponent other,
  ) {
    var normal = Vector2.zero();
    var depth = double.maxFinite;

    final verticesA = CollisionUtil.getPolygonVertices(shapeA);
    final verticesB = CollisionUtil.getPolygonVertices(shapeB);

    final normalAndDepthA = CollisionUtil.getNormalAndDepth(
      verticesA,
      verticesB,
    );

    if (normalAndDepthA.depth < depth) {
      depth = normalAndDepthA.depth;
      normal = normalAndDepthA.normal;
    }
    final normalAndDepthB = CollisionUtil.getNormalAndDepth(
      verticesB,
      verticesA,
      insverted: true,
    );

    if (normalAndDepthB.depth < depth) {
      depth = normalAndDepthB.depth;
      normal = normalAndDepthB.normal;
    }

    final direction = shapeB.absoluteCenter - shapeA.absoluteCenter;

    if (direction.dot(normal) < 0) {
      normal = -normal;
    }

    return (normal: normal, depth: depth);
  }

  ({Vector2 normal, double depth}) _intersectCirclePolygon(
    ShapeHitbox shapeA,
    CircleHitbox shapeB,
    PositionComponent other, {
    bool inverted = false,
  }) {
    var normal = Vector2.zero();
    var depth = double.maxFinite;
    var axis = Vector2.zero();
    var axisDepth = 0.0;

    final vertices = CollisionUtil.getPolygonVertices(shapeA);

    for (var i = 0; i < vertices.length; i++) {
      final va = vertices[i];
      final vb = vertices[(i + 1) % vertices.length];

      final edge = vb - va;
      axis = Vector2(-edge.y, edge.x);
      axis = axis.normalized();

      final pA = CollisionUtil.projectVertices(vertices, axis);
      final pB = CollisionUtil.projectCircle(
        shapeB.absoluteCenter,
        shapeB.radius,
        axis,
      );

      axisDepth = min(pB.max - pA.min, pA.max - pB.min);

      if (axisDepth < depth) {
        depth = axisDepth;
        normal = axis;
      }
    }

    final cpIndex = CollisionUtil.findClosesPointOnPolygon(
      shapeB.absoluteCenter,
      vertices,
    );
    final cp = vertices[cpIndex];

    axis = cp - shapeB.absoluteCenter;
    axis = axis.normalized();

    final pA = CollisionUtil.projectVertices(vertices, axis);
    final pB = CollisionUtil.projectCircle(
      shapeB.absoluteCenter,
      shapeB.radius,
      axis,
    );

    axisDepth = min(pB.max - pA.min, pA.max - pB.min);

    if (axisDepth < depth) {
      depth = axisDepth;
      normal = axis;
    }

    final direction = inverted
        ? shapeA.absoluteCenter - shapeB.absoluteCenter
        : shapeB.absoluteCenter - shapeA.absoluteCenter;

    if (direction.dot(normal) < 0) {
      normal = -normal;
    }

    return (normal: normal, depth: depth);
  }

  ({Vector2 normal, double depth}) _intersectCircles(
    CircleHitbox shapeA,
    CircleHitbox shapeB,
  ) {
    var normal = Vector2.zero();
    var depth = double.maxFinite;

    final distance = shapeA.absoluteCenter.distanceTo(shapeB.absoluteCenter);
    final radii = shapeA.radius + shapeB.radius;

    normal = (shapeB.absoluteCenter - shapeA.absoluteCenter).normalized();
    depth = radii - distance;

    return (normal: normal, depth: depth);
  }

  ShapeHitbox? _getCollisionShapeHitbox(
    Iterable<ShapeHitbox> shapeHitboxes,
    Set<Vector2> intersectionPoints,
  ) {
    if (shapeHitboxes.isEmpty || intersectionPoints.isEmpty) {
      return null;
    }
    if (shapeHitboxes.length == 1) {
      return shapeHitboxes.first;
    }
    final distances = <ShapeHitbox, double>{};
    for (final hitbox in shapeHitboxes) {
      for (final element in intersectionPoints) {
        distances[hitbox] = hitbox.absoluteCenter.distanceTo(element);
        if (hitbox.containsPoint(element)) {
          return hitbox;
        }
      }
    }

    return distances.entries.reduce((a, b) => a.value < b.value ? a : b).key;
  }
}
