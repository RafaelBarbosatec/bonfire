import 'dart:math';
import 'dart:ui';

import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/collision/object_collision.dart';
import 'package:bonfire/util/direction.dart';
import 'package:bonfire/util/extensions/extensions.dart';
import 'package:bonfire/util/vector2rect.dart';
import 'package:flame/components.dart';

/// Mixin responsible for adding movements
mixin Movement on GameComponent {
  bool isIdle = true;
  double dtUpdate = 0;
  double speed = 100;
  Direction lastDirection = Direction.right;
  Direction lastDirectionHorizontal = Direction.right;

  /// Move player to Up
  void moveUp(double speed, {VoidCallback? onCollision}) {
    double innerSpeed = speed * dtUpdate;
    Vector2Rect displacement = position.translate(0, (innerSpeed * -1));

    if (_isCollision(displacement.position)) {
      onCollision?.call();
      return;
    }

    isIdle = false;
    position = displacement;
    lastDirection = Direction.up;
  }

  /// Move player to Down
  void moveDown(double speed, {VoidCallback? onCollision}) {
    double innerSpeed = speed * dtUpdate;
    Vector2Rect displacement = position.translate(0, innerSpeed);

    if (_isCollision(displacement.position)) {
      onCollision?.call();
      return;
    }

    isIdle = false;
    position = displacement;
    lastDirection = Direction.down;
  }

  /// Move player to Left
  void moveLeft(double speed, {VoidCallback? onCollision}) {
    double innerSpeed = speed * dtUpdate;
    Vector2Rect displacement = position.translate((innerSpeed * -1), 0);

    if (_isCollision(displacement.position)) {
      onCollision?.call();
      return;
    }

    isIdle = false;
    position = displacement;
    lastDirection = Direction.left;
    lastDirectionHorizontal = Direction.left;
  }

  /// Move player to Right
  void moveRight(double speed, {VoidCallback? onCollision}) {
    double innerSpeed = speed * dtUpdate;
    Vector2Rect displacement = position.translate(innerSpeed, 0);

    if (_isCollision(displacement.position)) {
      onCollision?.call();
      return;
    }

    isIdle = false;
    position = displacement;
    lastDirection = Direction.right;
    lastDirectionHorizontal = Direction.right;
  }

  /// Move player to Up and Right
  void moveUpRight(double speedX, double speedY, {VoidCallback? onCollision}) {
    moveRight(speedX, onCollision: onCollision);
    moveUp(speedY, onCollision: onCollision);
    lastDirection = Direction.upRight;
  }

  /// Move player to Up and Left
  void moveUpLeft(double speedX, double speedY, {VoidCallback? onCollision}) {
    moveLeft(speedX, onCollision: onCollision);
    moveUp(speedY, onCollision: onCollision);
    lastDirection = Direction.upLeft;
  }

  /// Move player to Down and Left
  void moveDownLeft(double speedX, double speedY, {VoidCallback? onCollision}) {
    moveLeft(speedX, onCollision: onCollision);
    moveDown(speedY, onCollision: onCollision);
    lastDirection = Direction.downLeft;
  }

  /// Move player to Down and Right
  void moveDownRight(double speedX, double speedY,
      {VoidCallback? onCollision}) {
    moveRight(speedX, onCollision: onCollision);
    moveDown(speedY, onCollision: onCollision);
    lastDirection = Direction.downRight;
  }

  /// Move Player to direction by radAngle
  void moveFromAngle(double speed, double angle, {VoidCallback? onCollision}) {
    double nextX = (speed * dtUpdate) * cos(angle);
    double nextY = (speed * dtUpdate) * sin(angle);
    Offset nextPoint = Offset(nextX, nextY);

    Offset diffBase = Offset(
          position.rect.center.dx + nextPoint.dx,
          position.rect.center.dy + nextPoint.dy,
        ) -
        position.rect.center;

    Offset newDiffBase = diffBase;

    Vector2Rect newPosition = position.shift(newDiffBase);

    if (_isCollision(newPosition.position)) {
      onCollision?.call();
      return;
    }

    isIdle = false;
    position = newPosition;
  }

  /// Move to direction by radAngle with dodge obstacles
  void moveFromAngleDodgeObstacles(
    double speed,
    double angle, {
    VoidCallback? onCollision,
  }) {
    isIdle = false;
    double innerSpeed = (speed * dtUpdate);
    double nextX = innerSpeed * cos(angle);
    double nextY = innerSpeed * sin(angle);
    Offset nextPoint = Offset(nextX, nextY);

    Offset diffBase = Offset(position.center.dx + nextPoint.dx,
            position.center.dy + nextPoint.dy) -
        position.center;

    var collisionX = _verifyTranslateCollision(
      diffBase.dx,
      0,
    );
    var collisionY = _verifyTranslateCollision(
      0,
      diffBase.dy,
    );

    Offset newDiffBase = diffBase;

    if (collisionX) {
      newDiffBase = Offset(0, newDiffBase.dy);
    }
    if (collisionY) {
      newDiffBase = Offset(newDiffBase.dx, 0);
    }

    if (collisionX && !collisionY && newDiffBase.dy != 0) {
      var collisionY = _verifyTranslateCollision(
        0,
        innerSpeed,
      );
      if (!collisionY) newDiffBase = Offset(0, innerSpeed);
    }

    if (collisionY && !collisionX && newDiffBase.dx != 0) {
      var collisionX = _verifyTranslateCollision(
        innerSpeed,
        0,
      );
      if (!collisionX) newDiffBase = Offset(innerSpeed, 0);
    }

    if (newDiffBase == Offset.zero) {
      onCollision?.call();
    }
    this.position = position.shift(newDiffBase);
  }

  /// Check if performing a certain translate on the enemy collision occurs
  bool _verifyTranslateCollision(
    double translateX,
    double translateY,
  ) {
    if (this.isObjectCollision()) {
      return (this as ObjectCollision)
          .isCollision(
            displacement: this.position.position.translate(
                  translateX,
                  translateY,
                ),
          )
          .isNotEmpty;
    } else {
      return false;
    }
  }

  void idle() {
    isIdle = true;
  }

  @override
  void update(double dt) {
    super.update(dt);
    dtUpdate = dt;
  }

  bool _isCollision(Vector2 displacement) {
    if (this.isObjectCollision()) {
      (this as ObjectCollision).setCollisionOnlyVisibleScreen(this.isVisible);
      return (this as ObjectCollision)
          .isCollision(
            displacement: displacement,
          )
          .isNotEmpty;
    } else {
      return false;
    }
  }
}
