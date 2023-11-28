import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/pair.dart';

class CollisionUtil {

  static List<Vector2> getPolygonVertices(ShapeHitbox shape) {
    if (shape is PolygonComponent) {
      return (shape as PolygonComponent).absoluteVertices;
    }
    return [];
  }

  static Pair<Vector2, double> getNormalAndDepth(
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

      Vector2 pA = projectVertices(insverted ? verticesB : verticesA, axis);
      Vector2 pB = projectVertices(insverted ? verticesA : verticesB, axis);

      double axisDepth = min(pB.y - pA.x, pA.y - pB.x);
      if (axisDepth < depth) {
        depth = axisDepth;
        normal = axis;
      }
    }
    return Pair(normal, depth);
  }

  static Vector2 projectVertices(List<Vector2> vertices, Vector2 axis) {
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

  static Vector2 projectCircle(Vector2 center, double radius, Vector2 axis) {
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

  static int findClosesPointOnPolygon(Vector2 circleCenter, List<Vector2> vertices) {
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

extension PolygonComponentExt on PolygonComponent {
  List<Vector2> get absoluteVertices {
    Vector2 p = absolutePosition;
    return vertices.map((element) {
      return element.translated(p.x, p.y);
    }).toList();
  }
}
