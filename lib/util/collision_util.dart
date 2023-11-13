import 'package:bonfire/bonfire.dart';

class CollisionUtil {
  final Map<String, Direction> _directionsBlockedCache = {};
  static const _diagonalPercent = 0.2;

  final TriangleShape _triangleShape = TriangleShape(
    Vector2.zero(),
    Vector2.zero(),
    Vector2.zero(),
  );

  Direction getDirectionCollision(
    Rect rect,
    Vector2 point,
    Direction moveDirection,
    bool isCircle,
  ) {
    Vector2 c = rect.centerVector2;
    String key = c.normalized().toString() + point.normalized().toString();
    if (_directionsBlockedCache.containsKey(key)) {
      return _directionsBlockedCache[key]!;
    }
    if (isCircle) {
      double angle = BonfireUtil.angleBetweenPoints(c, point);
      return _directionsBlockedCache[key] = BonfireUtil.getDirectionFromAngle(
        angle,
        directionSpace: 22.5,
      );
    }

    if (point.y > rect.center.dy) {
      // bottom right
      _triangleShape.updatePoints(
        Vector2(rect.right, rect.bottom - rect.height * _diagonalPercent),
        Vector2(rect.right - rect.width * _diagonalPercent, rect.bottom),
        rect.center.toVector2(),
      );

      if (_triangleShape.containPoint(point)) {
        if (moveDirection == Direction.down) {
          return _directionsBlockedCache[key] = Direction.down;
        }
        if (moveDirection == Direction.right) {
          return _directionsBlockedCache[key] = Direction.right;
        }
        return _directionsBlockedCache[key] = Direction.downRight;
      }

      // bottom left
      _triangleShape.updatePoints(
        Vector2(rect.left, rect.bottom - rect.height * _diagonalPercent),
        Vector2(rect.left + rect.width * _diagonalPercent, rect.bottom),
        rect.center.toVector2(),
      );

      if (_triangleShape.containPoint(point)) {
        if (moveDirection == Direction.down) {
          return _directionsBlockedCache[key] = Direction.down;
        }
        if (moveDirection == Direction.left) {
          return _directionsBlockedCache[key] = Direction.left;
        }
        return _directionsBlockedCache[key] = Direction.downLeft;
      }

      // bottom
      _triangleShape.updatePoints(
        Vector2(rect.right, rect.bottom),
        Vector2(rect.left, rect.bottom),
        rect.center.toVector2(),
      );

      if (_triangleShape.containPoint(point)) {
        return _directionsBlockedCache[key] = Direction.down;
      }
    } else {
      // top right
      _triangleShape.updatePoints(
        Vector2(rect.right, rect.top + rect.height * _diagonalPercent),
        Vector2(rect.right - rect.width * _diagonalPercent, rect.top),
        rect.center.toVector2(),
      );

      if (_triangleShape.containPoint(point)) {
        if (moveDirection == Direction.up) {
          return _directionsBlockedCache[key] = Direction.up;
        }
        if (moveDirection == Direction.right) {
          return _directionsBlockedCache[key] = Direction.right;
        }
        return _directionsBlockedCache[key] = Direction.upRight;
      }

      // top left
      _triangleShape.updatePoints(
        Vector2(rect.left, rect.top + rect.height * _diagonalPercent),
        Vector2(rect.left + rect.width * _diagonalPercent, rect.top),
        rect.center.toVector2(),
      );

      if (_triangleShape.containPoint(point)) {
        if (moveDirection == Direction.up) {
          return _directionsBlockedCache[key] = Direction.up;
        }
        if (moveDirection == Direction.left) {
          return _directionsBlockedCache[key] = Direction.left;
        }
        return _directionsBlockedCache[key] = Direction.upLeft;
      }

      //top
      _triangleShape.updatePoints(
        Vector2(rect.left, rect.top),
        Vector2(rect.right, rect.top),
        rect.center.toVector2(),
      );

      if (_triangleShape.containPoint(point)) {
        return _directionsBlockedCache[key] = Direction.up;
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

    return moveDirection;
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
