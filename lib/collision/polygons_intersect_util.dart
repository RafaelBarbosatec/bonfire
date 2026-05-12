// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/collision/collision_util.dart';

abstract class PolygonsIntersectUtil {
  static ({Vector2 normal, double depth}) intersectPolygons(
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

  static ({Vector2 normal, double depth}) intersectCirclePolygon(
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

  static ({Vector2 normal, double depth}) intersectCircles(
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

  static ShapeHitbox? getCollisionShapeHitbox(
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