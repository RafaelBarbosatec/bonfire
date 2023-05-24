import 'package:bonfire/bonfire.dart';

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
      var myDisplacement = lastDisplacement.clone();

      if (shapers.length == 1) {
        var shape = shapers.first;

        var centerShape = shape.absoluteCenter;
        midPoint = intersectionPoints.reduce((value, element) {
              return Vector2(value.x + element.x, value.y + element.y);
            }) /
            intersectionPoints.length.toDouble();

        var normalized = (centerShape - midPoint);
        var yAbs = normalized.y.abs();
        var xAbs = normalized.x.abs();
        if ((yAbs - xAbs).abs() > 0.5) {
          if (yAbs > xAbs) {
            myDisplacement = myDisplacement.copyWith(x: 0);
          } else if (yAbs < xAbs) {
            myDisplacement = myDisplacement.copyWith(y: 0);
          }
        } else {
          myDisplacement.setZero();
        }

        position += myDisplacement * -1;
        stopFromCollision(
          isX: myDisplacement.x.abs() > 0,
          isY: myDisplacement.y.abs() > 0,
        );
      }

      super.onCollision(intersectionPoints, other);
    }
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
