import 'dart:async';

import 'package:bonfire/bonfire.dart';

/// Mixin responsible for adding stop the movement when happen collision
mixin BlockMovementCollision on Movement {
  final Map<String, Direction> _directionsBlockedCache = {};

  Rect? _shapeRectNormalized;

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
      if (_shapeRectNormalized != null) {
        var reverseDisplacement = lastDisplacement.clone();

        midPoint = intersectionPoints.reduce(
          (value, element) => value + element,
        );
        midPoint /= intersectionPoints.length.toDouble();
        midPoint = midPoint - position;
        midPoint.lerp(_shapeRectNormalized!.center.toVector2(), 0.2);

        var direction = _getDirectionCollision(
          _shapeRectNormalized!,
          midPoint,
        );

        reverseDisplacement = _adjustDisplacement(
          reverseDisplacement,
          direction,
        );

        position += reverseDisplacement * -1;
        stopFromCollision(
          isX: reverseDisplacement.x.abs() > 0,
          isY: reverseDisplacement.y.abs() > 0,
        );
        onBlockedMovement(other, direction);
      }

      super.onCollision(intersectionPoints, other);
    }
  }

  Direction? _getDirectionCollision(Rect rect, Vector2 point) {
    String key = rect.toString() + point.normalized().toString();
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

  @override
  FutureOr<void> add(Component component) {
    if (component is ShapeHitbox) {
      _shapeRectNormalized = component.toRect();
    }
    return super.add(component);
  }

  Vector2 _adjustDisplacement(
    Vector2 reverseDisplacement,
    Direction? direction,
  ) {
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
    return reverseDisplacement;
  }
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
