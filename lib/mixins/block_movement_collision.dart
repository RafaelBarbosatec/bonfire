import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/collision_util.dart';

/// Mixin responsible for adding stop the movement when happen collision
mixin BlockMovementCollision on Movement {
  final _collisionUtil = CollisionUtil();

  Rect? _shapeRectNormalized;
  Direction? lasDirectionCollision;

  bool onBlockMovement(
    Set<Vector2> intersectionPoints,
    GameComponent other,
  ) {
    return true;
  }

  void onBlockedMovement(
    PositionComponent other,
    Direction? direction,
    Vector2 lastDisplacement,
  ) {
    final reverseDisplacement = _adjustDisplacement(
      lastDisplacement,
      direction,
    );

    position += reverseDisplacement * -1;
    angle = lastAngle;
    stopFromCollision(
      isX: reverseDisplacement.x.abs() > 0,
      isY: reverseDisplacement.y.abs() > 0,
    );
  }

  Vector2 midPoint = Vector2.zero();

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    bool stopOtherMovement = true;
    bool stopMovement = other is GameComponent
        ? onBlockMovement(intersectionPoints, other)
        : true;
    if (stopMovement && other is BlockMovementCollision) {
      stopOtherMovement = other.onBlockMovement(intersectionPoints, this);
    }
    if (stopMovement && stopOtherMovement && other is! Sensor) {
      if (_shapeRectNormalized != null) {
        midPoint = intersectionPoints.reduce(
          (value, element) => value + element,
        );
        midPoint /= intersectionPoints.length.toDouble();
        midPoint = midPoint - position;
        midPoint.lerp(_shapeRectNormalized!.center.toVector2(), 0.2);

        lasDirectionCollision = _collisionUtil.getDirectionCollision(
          _shapeRectNormalized!,
          midPoint,
        );

        onBlockedMovement(
          other,
          lasDirectionCollision,
          lastDisplacement.clone(),
        );
      }
    }
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
