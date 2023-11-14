import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/collision_util.dart';

/// Mixin responsible for adding stop the movement when happen collision
mixin BlockMovementCollision on Movement {
  final _collisionUtil = CollisionUtil();

  Rect? _shapeRectNormalized;
  Direction? _lasDirectionCollision;
  Vector2 _lastDisplacementCollision = Vector2.zero();
  Vector2 _midPoint = Vector2.zero();
  bool _isCicleHitbox = false;

  bool onBlockMovement(
    Set<Vector2> intersectionPoints,
    GameComponent other,
  ) {
    return true;
  }

  void onBlockedMovement(
    PositionComponent other,
    Direction direction,
  ) {
    final reverseDisplacement = _adjustDisplacement(
      _lastDisplacementCollision,
      direction,
    );

    superPosition = position - reverseDisplacement;
    if (lastAngle > 0) {
      angle = lastAngle;
    }

    stopFromCollision(
      isX: direction.isSameXDirection(_lastDisplacementCollision.x) == true,
      isY: direction.isSameYDirection(_lastDisplacementCollision.y) == true,
    );
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is Sensor) return;
    bool stopMovement = other is GameComponent
        ? onBlockMovement(intersectionPoints, other)
        : true;
    bool stopOtherMovement = other is BlockMovementCollision
        ? other.onBlockMovement(intersectionPoints, this)
        : true;
    if (!stopMovement || !stopOtherMovement) {
      return;
    }
    _lastDisplacementCollision = lastDisplacement.clone();
    if (_shapeRectNormalized != null) {
      _midPoint = intersectionPoints.reduce(
        (value, element) => value + element,
      );
      _midPoint /= intersectionPoints.length.toDouble();
      _midPoint = _midPoint - position;
      _midPoint.lerp(_shapeRectNormalized!.center.toVector2(), 0.2);

      _lasDirectionCollision = _collisionUtil.getDirectionCollision(
        _shapeRectNormalized!,
        _midPoint,
        lastDirection,
        _isCicleHitbox,
      );

      onBlockedMovement(
        other,
        _lasDirectionCollision!,
      );
    }
  }

  @override
  FutureOr<void> add(Component component) {
    if (component is ShapeHitbox) {
      _shapeRectNormalized = component.toRect();
    }
    _isCicleHitbox = component is CircleHitbox;
    return super.add(component);
  }

  Vector2 _adjustDisplacement(
    Vector2 reverseDisplacement,
    Direction direction,
  ) {
    switch (direction) {
      case Direction.right:
        if (lastDirection.isVertical ||
            lastDirection == Direction.upRight ||
            lastDirection == Direction.downRight) {
          reverseDisplacement = reverseDisplacement.copyWith(y: 0);
        }
        break;
      case Direction.left:
        if (lastDirection.isVertical ||
            lastDirection == Direction.upLeft ||
            lastDirection == Direction.downLeft) {
          reverseDisplacement = reverseDisplacement.copyWith(y: 0);
        }
        break;
      case Direction.up:
        if (lastDirection.isHorizontal ||
            lastDirection == Direction.upLeft ||
            lastDirection == Direction.upRight) {
          reverseDisplacement = reverseDisplacement.copyWith(x: 0);
        }
        break;
      case Direction.down:
        if (lastDirection.isHorizontal ||
            lastDirection == Direction.downLeft ||
            lastDirection == Direction.downRight) {
          reverseDisplacement = reverseDisplacement.copyWith(x: 0);
        }
        break;

      case Direction.upLeft:
        if (lastDirection.isRightSide) {
          reverseDisplacement = reverseDisplacement.copyWith(x: 0);
        } else if (lastDirection.isDownSide) {
          reverseDisplacement = reverseDisplacement.copyWith(y: 0);
        } else {
          if (lastDirection == Direction.up) {
            reverseDisplacement.add(Vector2(-dtSpeed, 0));
          } else if (lastDirection == Direction.left) {
            reverseDisplacement.add(Vector2(0, -dtSpeed));
          }
        }
        break;
      case Direction.upRight:
        if (lastDirection.isLeftSide) {
          reverseDisplacement = reverseDisplacement.copyWith(x: 0);
        } else if (lastDirection.isDownSide) {
          reverseDisplacement = reverseDisplacement.copyWith(y: 0);
        } else {
          if (lastDirection == Direction.up) {
            reverseDisplacement.add(Vector2(dtSpeed, 0));
          } else if (lastDirection == Direction.right) {
            reverseDisplacement.add(Vector2(0, -dtSpeed));
          }
        }
        break;
      case Direction.downLeft:
        if (lastDirection.isRightSide) {
          reverseDisplacement = reverseDisplacement.copyWith(x: 0);
        } else if (lastDirection.isUpSide) {
          reverseDisplacement = reverseDisplacement.copyWith(y: 0);
        } else {
          if (lastDirection == Direction.down) {
            reverseDisplacement.add(Vector2(-dtSpeed, 0));
          } else if (lastDirection == Direction.left) {
            reverseDisplacement.add(Vector2(0, dtSpeed));
          }
        }
        break;
      case Direction.downRight:
        if (lastDirection.isLeftSide) {
          reverseDisplacement = reverseDisplacement.copyWith(x: 0);
        } else if (lastDirection.isUpSide) {
          reverseDisplacement = reverseDisplacement.copyWith(y: 0);
        } else {
          if (lastDirection == Direction.down) {
            reverseDisplacement.add(Vector2(dtSpeed, 0));
          } else if (lastDirection == Direction.right) {
            reverseDisplacement.add(Vector2(0, dtSpeed));
          }
        }
        break;
    }
    return reverseDisplacement;
  }
}
