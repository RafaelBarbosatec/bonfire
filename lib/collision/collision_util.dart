import 'dart:math';

import 'package:bonfire/bonfire.dart';

class CollisionUtil {
  static List<Vector2> getPolygonVertices(ShapeHitbox shape) {
    if (shape is PolygonComponent) {
      return (shape as PolygonComponent).absoluteVertices;
    }
    return [];
  }

  static ({Vector2 normal, double depth}) getNormalAndDepth(
    List<Vector2> verticesA,
    List<Vector2> verticesB, {
    bool insverted = false,
  }) {
    Vector2 normal = Vector2.zero();
    double depth = double.maxFinite;
    for (int i = 0; i < verticesA.length; i++) {
      Vector2 va = verticesA[i];
      Vector2 vb = verticesA[(i + 1) % verticesA.length];

      Vector2 edge = vb - va;
      Vector2 axis = Vector2(-edge.y, edge.x);
      axis = axis.normalized();

      final pA = projectVertices(insverted ? verticesB : verticesA, axis);
      final pB = projectVertices(insverted ? verticesA : verticesB, axis);

      double axisDepth = min(pB.max - pA.min, pA.max - pB.min);
      if (axisDepth < depth) {
        depth = axisDepth;
        normal = axis;
      }
    }
    return (normal: normal, depth: depth);
  }

  static ({double min, double max}) projectVertices(
    List<Vector2> vertices,
    Vector2 axis,
  ) {
    double min = double.maxFinite;
    double max = -double.maxFinite;
    for (var v in vertices) {
      double proj = v.dot(axis);

      if (proj < min) {
        min = proj;
      }
      if (proj > max) {
        max = proj;
      }
    }
    return (min: min, max: max);
  }

  static ({double min, double max}) projectCircle(
      Vector2 center, double radius, Vector2 axis) {
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
    return (min: min, max: max);
  }

  static int findClosesPointOnPolygon(
    Vector2 circleCenter,
    List<Vector2> vertices,
  ) {
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
}

final _cachedGlobalVertices = ValueCache<List<Vector2>>();

extension PolygonComponentExt on PolygonComponent {
  List<Vector2> get absoluteVertices {
    final Vector2 p = absolutePosition;
    final adjustedVerticies =
        absoluteAngle == 0 ? vertices : rotatedVerticesBonfire(absoluteAngle);

    final result = adjustedVerticies.map((element) {
      return element.translated(p.x, p.y);
    }).toList(growable: false);
    return result;
  }

  /// gives back the shape vectors multiplied by the size and scale
  List<Vector2> rotatedVerticesBonfire(double parentAngle) {
    final angle = parentAngle;
    if (!_cachedGlobalVertices.isCacheValid<dynamic>(<dynamic>[
      size,
      angle,
    ])) {
      final globalVertices = List.generate(
        vertices.length,
        (_) => Vector2.zero(),
        growable: false,
      );

      for (var i = 0; i < vertices.length; i++) {
        final vertex = vertices[i];
        globalVertices[i]
          ..setFrom(vertex)
          //..multiply(scale)
          ..rotate(angle);
      }

      _cachedGlobalVertices.updateCache<dynamic>(
        globalVertices,
        <dynamic>[size.clone(), angle],
      );
    }
    return _cachedGlobalVertices.value!;
  }
}
