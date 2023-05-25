import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';

/// Mixin responsible for adding collision
mixin BlockMovementCollision on Movement {
  bool onBlockMovement(
    Set<Vector2> intersectionPoints,
    GameComponent other,
  ) {
    return true;
  }

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
      var reverseDisplacement = lastDisplacement.clone();

      if (shapers.length == 1) {
        var shapeRect = shapers.first.toAbsoluteRect();

        midPoint = intersectionPoints.reduce(
          (value, element) => value + element,
        );
        midPoint /= intersectionPoints.length.toDouble();
        midPoint.lerp(shapeRect.center.toVector2(), 0.3);

        var direction = _getDirectionCollision(
          shapeRect,
          midPoint,
        );

        if (direction != null) {
          if ((direction == Direction.down || direction == Direction.up) &&
              reverseDisplacement.x.abs() > 0) {
            reverseDisplacement = reverseDisplacement.copyWith(x: 0);
          } else if ((direction == Direction.left ||
                  direction == Direction.right) &&
              reverseDisplacement.y.abs() > 0) {
            reverseDisplacement = reverseDisplacement.copyWith(y: 0);
          }
        } else {
          reverseDisplacement.setZero();
        }

        // var normalized = (shape.absoluteCenter - midPoint);
        // var yAbs = double.parse(normalized.y.abs().toStringAsFixed(2));
        // var xAbs = double.parse(normalized.x.abs().toStringAsFixed(2));
        // if ((yAbs - xAbs).abs() >= speed * dtUpdate) {
        //   if (yAbs > xAbs) {
        //     myDisplacement = myDisplacement.copyWith(x: 0);
        //   } else if (yAbs < xAbs) {
        //     myDisplacement = myDisplacement.copyWith(y: 0);
        //   }
        // } else {
        //   myDisplacement.setZero();
        // }

        position += reverseDisplacement * -1;
        stopFromCollision(
          isX: reverseDisplacement.x.abs() > 0,
          isY: reverseDisplacement.y.abs() > 0,
        );
      }

      super.onCollision(intersectionPoints, other);
    }
  }

  Direction? _getDirectionCollision(Rect rect, Vector2 point) {
    if (point.y > rect.center.dy) {
      // bottom
      TriangleShape t3 = TriangleShape(
        Vector2(rect.right, rect.bottom),
        Vector2(rect.left, rect.bottom),
        rect.center.toVector2(),
      );

      if (t3.containPoint(point)) {
        return Direction.down;
      }
    } else {
//top
      TriangleShape t1 = TriangleShape(
        Vector2(rect.left, rect.top),
        Vector2(rect.right, rect.top),
        rect.center.toVector2(),
      );

      if (t1.containPoint(point)) {
        return Direction.up;
      }
    }

    if (point.x < rect.center.dx) {
// left
      TriangleShape t4 = TriangleShape(
        Vector2(rect.left, rect.bottom),
        Vector2(rect.left, rect.top),
        rect.center.toVector2(),
      );

      if (t4.containPoint(point)) {
        return Direction.left;
      }
    } else {
//right
      TriangleShape t2 = TriangleShape(
        Vector2(rect.right, rect.top),
        Vector2(rect.right, rect.bottom),
        rect.center.toVector2(),
      );

      if (t2.containPoint(point)) {
        return Direction.right;
      }
    }

    return null;
  }

  // @override
  // void render(Canvas canvas) {
  //   canvas.save();
  //   canvas.translate(-x, -y);
  //   canvas.drawPoints(
  //       PointMode.points,
  //       [midPoint.toOffset()],
  //       Paint()
  //         ..color = Colors.green
  //         ..strokeWidth = 2);
  //   canvas.restore();
  //   super.render(canvas);
  // }
}

class TriangleShape {
  final Vector2 p1;
  final Vector2 p2;
  final Vector2 p3;

  TriangleShape(this.p1, this.p2, this.p3);

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
