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
    var normal = Vector2.zero();
    var depth = double.maxFinite;
    for (var i = 0; i < verticesA.length; i++) {
      final va = verticesA[i];
      final vb = verticesA[(i + 1) % verticesA.length];

      final edge = vb - va;
      var axis = Vector2(-edge.y, edge.x);
      axis = axis.normalized();

      final pA = projectVertices(insverted ? verticesB : verticesA, axis);
      final pB = projectVertices(insverted ? verticesA : verticesB, axis);

      final double axisDepth = min(pB.max - pA.min, pA.max - pB.min);
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
    var min = double.maxFinite;
    var max = -double.maxFinite;
    for (final v in vertices) {
      final proj = v.dot(axis);

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
    Vector2 center,
    double radius,
    Vector2 axis,
  ) {
    final direction = axis.normalized();
    final directionAndRadius = direction * radius;

    final p1 = center + directionAndRadius;
    final p2 = center - directionAndRadius;

    var min = p1.dot(axis);
    var max = p2.dot(axis);

    if (min > max) {
      // swap the min and max values.
      final t = min;
      min = max;
      max = t;
    }
    return (min: min, max: max);
  }

  static int findClosesPointOnPolygon(
    Vector2 circleCenter,
    List<Vector2> vertices,
  ) {
    var result = -1;
    var minDistance = double.maxFinite;

    for (var i = 0; i < vertices.length; i++) {
      final v = vertices[i];
      final distance = v.distanceTo(circleCenter);

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
    final p = absoluteTopLeftPosition;
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
