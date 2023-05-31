import 'dart:ui';

import 'package:bonfire/bonfire.dart';

/// Mixin responsible for adding collision
mixin BlockMovementCollision on Movement {
  final Map<String, Direction> _directionsBlockedCache = {};
  final TriangleShape _triangleShape = TriangleShape(
    Vector2.zero(),
    Vector2.zero(),
    Vector2.zero(),
  );
  bool onBlockMovement(
    Set<Vector2> intersectionPoints,
    GameComponent other,
  ) {
    return true;
  }

  void onBlockedMovement(
    PositionComponent other,
    Direction? direction,
  ) {}

  Vector2 midPoint = Vector2.zero();

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    bool stopOtherMovement = true;
    bool stopMovement = other is GameComponent
        ? onBlockMovement(intersectionPoints, other)
        : true;
    if (stopMovement && other is BlockMovementCollision) {
      stopOtherMovement = other.onBlockMovement(intersectionPoints, this);
    }
    if (stopMovement && stopOtherMovement && other is! Sensor) {
      var shapers = children.whereType<ShapeHitbox>();

      if (shapers.length == 1) {
        var reverseDisplacement = lastDisplacement.clone();
        var shape = shapers.first;
        var shapeRect = shape.toAbsoluteRect();

        midPoint = intersectionPoints.reduce(
          (value, element) => value + element,
        );
        midPoint /= intersectionPoints.length.toDouble();
        midPoint.lerp(shape.absoluteCenter, 0.2);

        var direction = _getDirectionCollision(
          shapeRect,
          midPoint,
        );

        if (direction != null) {
          if ((direction == Direction.down || direction == Direction.up) &&
              reverseDisplacement.x.abs() > 0) {
            if (direction == lastDirectionVertical) {
              reverseDisplacement = reverseDisplacement.copyWith(x: 0);
            } else {
              reverseDisplacement.setZero();
            }
          } else if ((direction == Direction.left ||
                  direction == Direction.right) &&
              reverseDisplacement.y.abs() > 0) {
            if (direction == lastDirectionHorizontal) {
              reverseDisplacement = reverseDisplacement.copyWith(y: 0);
            } else {
              reverseDisplacement.setZero();
            }
          }
        }

        // var diffCenter = (shape.absoluteCenter - midPoint);
        // var yAbs = diffCenter.y.abs();
        // var xAbs = diffCenter.x.abs();

        // if (yAbs > xAbs) {
        //   if (_getVerticalDirection(diffCenter) == lastDirectionVertical) {
        //     reverseDisplacement = reverseDisplacement.copyWith(x: 0);
        //   } else {
        //     reverseDisplacement.setZero();
        //   }
        // } else if (yAbs < xAbs) {
        //   if (_getHorizontalDirection(diffCenter) == lastDirectionHorizontal) {
        //     reverseDisplacement = reverseDisplacement.copyWith(y: 0);
        //   } else {
        //     reverseDisplacement.setZero();
        //   }
        // }

        if (!reverseDisplacement.isZero()) {
          position += reverseDisplacement * -1;
          stopFromCollision(
            isX: reverseDisplacement.x.abs() > 0,
            isY: reverseDisplacement.y.abs() > 0,
          );
        }
        onBlockedMovement(other, direction);
      }

      super.onCollision(intersectionPoints, other);
    }
  }

  Direction? _getDirectionCollision(Rect rect, Vector2 point) {
    String key = rect.toString() + point.toString();
    if (_directionsBlockedCache.containsKey(key)) {
      return _directionsBlockedCache[key];
    }
    if (point.y > rect.center.dy) {
      // bottom
      _triangleShape.updatePoints(
        Vector2(rect.right, rect.bottom),
        Vector2(rect.left, rect.bottom),
        rect.center.toVector2(),
      );

      if (_triangleShape.containPoint(point)) {
        _directionsBlockedCache[key] = Direction.down;
        return Direction.down;
      }
    } else {
//top
      _triangleShape.updatePoints(
        Vector2(rect.left, rect.top),
        Vector2(rect.right, rect.top),
        rect.center.toVector2(),
      );

      if (_triangleShape.containPoint(point)) {
        _directionsBlockedCache[key] = Direction.up;
        return Direction.up;
      }
    }

    if (point.x < rect.center.dx) {
// left

      _triangleShape.updatePoints(
        Vector2(rect.left, rect.bottom),
        Vector2(rect.left, rect.top),
        rect.center.toVector2(),
      );
      if (_triangleShape.containPoint(point)) {
        _directionsBlockedCache[key] = Direction.left;
        return Direction.left;
      }
    } else {
//right

      _triangleShape.updatePoints(
        Vector2(rect.right, rect.top),
        Vector2(rect.right, rect.bottom),
        rect.center.toVector2(),
      );

      if (_triangleShape.containPoint(point)) {
        _directionsBlockedCache[key] = Direction.right;
        return Direction.right;
      }
    }

    return null;
  }

  // Direction _getHorizontalDirection(Vector2 diffCenter) {
  //   return (diffCenter.x > 0 ? Direction.left : Direction.right);
  // }

  // Direction _getVerticalDirection(Vector2 diffCenter) {
  //   return (diffCenter.y > 0 ? Direction.up : Direction.down);
  // }

  // @override
  // void render(Canvas canvas) {
  //   super.render(canvas);
  //   canvas.save();
  //   canvas.translate(-x, -y);
  //   canvas.drawPoints(
  //       PointMode.points,
  //       [midPoint.toOffset()],
  //       Paint()
  //         ..color = Colors.red
  //         ..strokeWidth = 2);
  //   canvas.restore();
  // }
}

class TriangleShape {
  Vector2 p1;
  Vector2 p2;
  Vector2 p3;

  TriangleShape(this.p1, this.p2, this.p3);

  void updatePoints(Vector2 p1, Vector2 p2, Vector2 p3) {
    this.p1 = p1;
    this.p2 = p2;
    this.p3 = p3;
  }

  Vector2 get center => (p1 + p2 + p3) / 3;

  bool containPoint(Vector2 point) {
    double d1, d2, d3;
    bool hasNeg, hasPos;

    d1 = _sign(point, p1, p2);
    d2 = _sign(point, p2, p3);
    d3 = _sign(point, p3, p1);

    hasNeg = (d1 < 0) || (d2 < 0) || (d3 < 0);
    hasPos = (d1 > 0) || (d2 > 0) || (d3 > 0);

    return !(hasNeg && hasPos);
  }

  double _sign(Vector2 p1, Vector2 p2, Vector2 p3) {
    return (p1.x - p3.x) * (p2.y - p3.y) - (p2.x - p3.x) * (p1.y - p3.y);
  }
}
