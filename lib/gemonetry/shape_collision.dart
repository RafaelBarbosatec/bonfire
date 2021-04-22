import 'dart:math';

import 'package:flame/extensions.dart';

import 'circle.dart';
import 'polygon.dart';
import 'rectangle.dart';
import 'shape.dart';

/// Class responsible to verify collision of the Shapes.
/// Code based from: https://github.com/hahafather007/collision_check
class ShapeCollision {
  static bool isCollision(Shape a, Shape b) {
    if (a is RectangleShape) {
      if (b is RectangleShape) {
        return rectToRect(a, b);
      } else if (b is CircleShape) {
        return rectToCircle(a, b);
      } else if (b is PolygonShape) {
        return rectToPolygon(a, b);
      } else {
        return false;
      }
    } else if (a is CircleShape) {
      if (b is RectangleShape) {
        return rectToCircle(b, a);
      } else if (b is CircleShape) {
        return circleToCircle(a, b);
      } else if (b is PolygonShape) {
        return circleToPolygon(a, b);
      } else {
        return false;
      }
    } else {
      if (b is RectangleShape && a is PolygonShape) {
        return rectToPolygon(b, a);
      } else if (b is CircleShape && a is PolygonShape) {
        return circleToPolygon(b, a);
      } else if (b is PolygonShape && a is PolygonShape) {
        return polygonToPolygon(a, b);
      } else {
        return false;
      }
    }
  }

  static bool rectToRect(RectangleShape a, RectangleShape b) {
    return a.rect.overlaps(b.rect);
  }

  static bool rectToCircle(RectangleShape a, CircleShape b) {
    if (!rectToRect(a, b.rect)) return false;

    final points = [
      a.leftTop,
      a.rightTop,
      a.rightBottom,
      a.leftBottom,
      a.leftTop,
    ];
    for (var i = 0; i < points.length - 1; i++) {
      final distance = getNearestDistance(points[i], points[i + 1], b.center);
      if (_getFixDouble(distance) <= b.radius) return true;
    }

    return false;
  }

  static bool rectToPolygon(RectangleShape a, PolygonShape b) {
    if (!rectToRect(a, b.rect)) return false;
    if (!isLinesShadowOver(
        a.leftTop, a.rightBottom, b.rect.leftTop, b.rect.rightBottom))
      return false;

    final pointsA = [
      a.leftTop,
      a.rightTop,
      a.rightBottom,
      a.leftBottom,
      a.leftTop,
    ];
    final pointsB = b.points.toList()..add(b.points.first);

    for (var i = 0; i < pointsA.length - 1; i++) {
      final pointA = pointsA[i];
      final pointB = pointsA[i + 1];
      for (var j = 0; j < pointsB.length - 1; j++) {
        final pointC = pointsB[j];
        final pointD = pointsB[j + 1];

        if (!isLinesShadowOver(pointA, pointB, pointC, pointD)) {
          continue;
        }

        if (isLinesOver(pointA, pointB, pointC, pointD)) {
          return true;
        }
      }
    }

    return false;
  }

  static bool circleToCircle(CircleShape a, CircleShape b) {
    if (!rectToRect(a.rect, b.rect)) return false;

    final distance = a.radius + b.radius;
    final w = a.center.x - b.center.x;
    final h = a.center.y - b.center.y;

    return sqrt(w * w + h * h) <= distance;
  }

  static bool circleToPolygon(CircleShape a, PolygonShape b) {
    if (!rectToRect(a.rect, b.rect)) return false;

    if (b.points.isNotEmpty) {
      final points = b.points.toList();
      points.add(points.first);
      for (var i = 0; i < points.length - 1; i++) {
        final distance = getNearestDistance(points[i], points[i + 1], a.center);
        if (distance <= a.radius) {
          return true;
        }
      }
    }

    return false;
  }

  static bool polygonToPolygon(PolygonShape a, PolygonShape b) {
    if (!rectToRect(a.rect, b.rect)) return false;

    final pointsA = a.points.toList()..add(a.points.first);
    final pointsB = b.points.toList()..add(b.points.first);
    for (var i = 0; i < pointsA.length - 1; i++) {
      final pointA = pointsA[i];
      final pointB = pointsA[i + 1];

      if (!isLinesShadowOver(
          pointA, pointB, b.rect.leftTop, b.rect.rightBottom)) {
        continue;
      }

      for (var j = 0; j < pointsB.length - 1; j++) {
        final pointC = pointsB[j];
        final pointD = pointsB[j + 1];

        if (!isLinesShadowOver(pointA, pointB, pointC, pointD)) {
          continue;
        }

        if (isLinesOver(pointA, pointB, pointC, pointD)) {
          return true;
        }
      }
    }

    return false;
  }

  /// Get [o] point distance [o1] and [o2] line segment distance
  /// https://blog.csdn.net/yjukh/article/details/5213577
  static double getNearestDistance(Vector2 o1, Vector2 o2, Vector2 o) {
    if (o1 == o || o2 == o) return 0;

    final a = o2.distanceTo(o);
    final b = o1.distanceTo(o);
    final c = o1.distanceTo(o2);

    if (a * a >= b * b + c * c) return b;
    if (b * b >= a * a + c * c) return a;

    // 海伦公式
    final l = (a + b + c) / 2;
    final area = sqrt(l * (l - a) * (l - b) * (l - c));

    return 2 * area / c;
  }

  /// Obtain the [double] value with 4 decimal places to avoid errors caused by precision problems
  static double _getFixDouble(double value) {
    return double.parse(value.toStringAsFixed(4));
  }

  /// Rapid rejection experiment
  /// Determine whether the projections of the line segment [a]~[b] and the line segment [c]~[d] on the x-axis and y-axis have a common area
  static bool isLinesShadowOver(Vector2 a, Vector2 b, Vector2 c, Vector2 d) {
    if (min(a.x, b.x) > max(c.x, d.x) ||
        min(c.x, d.x) > max(a.x, b.x) ||
        min(a.y, b.y) > max(c.y, d.y) ||
        min(c.y, d.y) > max(a.y, b.y)) {
      return false;
    }

    return true;
  }

  /// Straddle experiment
  /// Determine whether the line segment [a]~[b] and the line segment [c]~[d]
  /// https://www.rogoso.info/%E5%88%A4%E6%96%AD%E7%BA%BF%E6%AE%B5%E7%9B%B8%E4%BA%A4/
  static bool isLinesOver(Vector2 a, Vector2 b, Vector2 c, Vector2 d) {
    final ac = VectorVector(a, c);
    final ad = VectorVector(a, d);
    final bc = VectorVector(b, c);
    final bd = VectorVector(b, d);
    final ca = ac.negative;
    final cb = bc.negative;
    final da = ad.negative;
    final db = bd.negative;

    return vectorProduct(ac, ad) * vectorProduct(bc, bd) <= 0 &&
        vectorProduct(ca, cb) * vectorProduct(da, db) <= 0;
  }

  static double vectorProduct(VectorVector a, VectorVector b) {
    return a.x * b.y - b.x * a.y;
  }
}

class VectorVector {
  final Vector2 start;
  final Vector2 end;
  final double x;
  final double y;

  VectorVector(this.start, this.end)
      : x = end.x - start.x,
        y = end.y - start.y;

  /// Vector negation
  VectorVector get negative => VectorVector(end, start);
}
