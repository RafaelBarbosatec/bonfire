import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';

class BonfireUtil {
  // ignore: constant_identifier_names
  static const PI_180 = (180 / pi);

  static Direction getDirectionFromAngle(double angle) {
    double degrees = angle * 180 / pi;

    if (degrees > -22.5 && degrees <= 22.5) {
      return Direction.right;
    }

    if (degrees > 22.5 && degrees <= 67.5) {
      return Direction.downRight;
    }

    if (degrees > 67.5 && degrees <= 112.5) {
      return Direction.down;
    }

    if (degrees > 112.5 && degrees <= 157.5) {
      return Direction.downLeft;
    }

    if ((degrees > 157.5 && degrees <= 180) ||
        (degrees >= -180 && degrees <= -157.5)) {
      return Direction.left;
    }

    if (degrees > -157.5 && degrees <= -112.5) {
      return Direction.upLeft;
    }

    if (degrees > -112.5 && degrees <= -67.5) {
      return Direction.up;
    }

    if (degrees > -67.5 && degrees <= -22.5) {
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
      default:
        return 0;
    }
  }

  static double angleBetweenPoints(Vector2 p1, Vector2 p2) {
    return atan2(p2.y - p1.y, p2.x - p1.x);
  }

  static Offset rotatePoint(Offset point, double angle, Offset center) {
    final s = sin(angle);
    final c = cos(angle);

    double x1 = point.dx - center.dx;
    double y1 = point.dy - center.dy;

    double x2 = x1 * c - y1 * s;
    double y2 = x1 * s + y1 * c;

    return Offset(x2 + center.dx, y2 + center.dy);
  }

  static Vector2 movePointByAngle(
    Vector2 point,
    double speed,
    double angle,
  ) {
    double nextX = speed * cos(angle);
    double nextY = speed * sin(angle);
    return Vector2(point.x + nextX, point.y + nextY);
  }

  static Vector2 diffMovePointByAngle(
    Vector2 point,
    double speed,
    double angle,
  ) {
    return movePointByAngle(point, speed, angle) - point;
  }
}
