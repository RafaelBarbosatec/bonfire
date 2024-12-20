import 'dart:math';

import 'package:bonfire/bonfire.dart';

class BonfireUtil {
  // ignore: constant_identifier_names
  static const PI_180 = 180 / pi;

  static Direction getDirectionFromAngle(
    double angle, {
    double directionSpace = 2.5,
  }) {
    final degrees = angle * PI_180;
    if (degrees > -directionSpace && degrees <= directionSpace) {
      return Direction.right;
    }

    if (degrees > directionSpace && degrees <= (90 - directionSpace)) {
      return Direction.downRight;
    }

    if (degrees > (90 - directionSpace) && degrees <= (90 + directionSpace)) {
      return Direction.down;
    }

    if (degrees > (90 + directionSpace) && degrees <= (180 - directionSpace)) {
      return Direction.downLeft;
    }

    if ((degrees > (180 - directionSpace) && degrees <= 180) ||
        (degrees >= -180 && degrees <= -(180 - directionSpace))) {
      return Direction.left;
    }

    if (degrees > -(180 - directionSpace) &&
        degrees <= -(90 + directionSpace)) {
      return Direction.upLeft;
    }

    if (degrees > -(90 + directionSpace) && degrees <= -(90 - directionSpace)) {
      return Direction.up;
    }

    if (degrees > -(90 - directionSpace) && degrees <= -directionSpace) {
      return Direction.upRight;
    }
    return Direction.left;
  }

  static double getAngleFromDirection(Direction direction) {
    switch (direction) {
      case Direction.left:
        return 180 / PI_180;
      case Direction.right:
        // we can't use 0 here because then no movement happens
        // we're just going as close to 0.0 without being exactly 0.0
        // if you have a better idea. Please be my guest
        return 0.0000001 / PI_180;
      case Direction.up:
        return -90 / PI_180;
      case Direction.down:
        return 90 / PI_180;
      case Direction.upLeft:
        return -135 / PI_180;
      case Direction.upRight:
        return -45 / PI_180;
      case Direction.downLeft:
        return 135 / PI_180;
      case Direction.downRight:
        return 45 / PI_180;
    }
  }

  static double angleBetweenPoints(Vector2 p1, Vector2 p2) {
    return atan2(p2.y - p1.y, p2.x - p1.x);
  }

  static double angleBetweenPointsOffset(Offset p1, Offset p2) {
    return atan2(p2.dy - p1.dy, p2.dx - p1.dx);
  }

  static Offset rotatePoint(Offset point, double angle, Offset center) {
    final s = sin(angle);
    final c = cos(angle);

    final x1 = point.dx - center.dx;
    final y1 = point.dy - center.dy;

    final x2 = x1 * c - y1 * s;
    final y2 = x1 * s + y1 * c;

    return Offset(x2 + center.dx, y2 + center.dy);
  }

  static Vector2 movePointByAngle(
    Vector2 point,
    double speed,
    double angle,
  ) {
    final nextX = speed * cos(angle);
    final nextY = speed * sin(angle);
    return Vector2(point.x + nextX, point.y + nextY);
  }

  static Vector2 diffMovePointByAngle(
    Vector2 point,
    double speed,
    double angle,
  ) {
    return movePointByAngle(point, speed, angle) - point;
  }

  static Vector2 vector2ByAngle(double angle, {double intensity = 1}) {
    var x = cos(angle) * intensity;
    var y = sin(angle) * intensity;
    if (x.abs() < 0.01) {
      x = 0;
    }
    if (y.abs() < 0.01) {
      y = 0;
    }
    return Vector2(x, y);
  }
}
