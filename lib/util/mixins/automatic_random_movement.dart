import 'dart:math';

import 'package:bonfire/bonfire.dart';

/// Mixin responsible for adding random movement like enemy walking through the scene
mixin AutomaticRandomMovement on Movement {
  Vector2 _targetRandomMovement = Vector2.zero();
  static const _KEY_INTERVAL_KEEP_STOPPED = 'INTERVAL_RANDOM_MOVEMENT';

  /// Method that bo used in [update] method.
  void runRandomMovement(
    double dt, {
    bool runOnlyVisibleInCamera = true,
    double speed = 20,
    int maxDistance = 50,
    int minDistance = 0,
    int timeKeepStopped = 2000,

    /// milliseconds
  }) {
    if (runOnlyVisibleInCamera &&
        !gameRef.camera.cameraRect.overlapComponent(this)) return;
    if (_targetRandomMovement == Vector2.zero()) {
      if (checkInterval(_KEY_INTERVAL_KEEP_STOPPED, timeKeepStopped, dt)) {
        int randomX = Random().nextInt(maxDistance.toInt());
        randomX = randomX < minDistance ? minDistance : randomX;
        int randomY = Random().nextInt(maxDistance.toInt());
        randomY = randomY < minDistance ? minDistance : randomY;
        int randomNegativeX = Random().nextBool() ? -1 : 1;
        int randomNegativeY = Random().nextBool() ? -1 : 1;
        _targetRandomMovement = position.translate(
          randomX.toDouble() * randomNegativeX,
          randomY.toDouble() * randomNegativeY,
        );
      }
    } else {
      bool canMoveX = (_targetRandomMovement.x - x).abs() > speed;
      bool canMoveY = (_targetRandomMovement.y - y).abs() > speed;

      bool canMoveLeft = false;
      bool canMoveRight = false;
      bool canMoveUp = false;
      bool canMoveDown = false;
      if (canMoveX) {
        if (_targetRandomMovement.x > x) {
          canMoveRight = true;
        } else {
          canMoveLeft = true;
        }
      }
      if (canMoveY) {
        if (_targetRandomMovement.y > y) {
          canMoveDown = true;
        } else {
          canMoveUp = true;
        }
      }

      if (canMoveLeft && canMoveUp) {
        moveUpLeft(speed, speed, onCollision: _cleanTargetMovementRandom);
      } else if (canMoveLeft && canMoveDown) {
        moveDownLeft(speed, speed, onCollision: _cleanTargetMovementRandom);
      } else if (canMoveRight && canMoveUp) {
        moveUpRight(speed, speed, onCollision: _cleanTargetMovementRandom);
      } else if (canMoveRight && canMoveDown) {
        moveDownRight(speed, speed, onCollision: _cleanTargetMovementRandom);
      } else if (canMoveRight) {
        moveRight(speed, onCollision: _cleanTargetMovementRandom);
      } else if (canMoveLeft) {
        moveLeft(speed, onCollision: _cleanTargetMovementRandom);
      } else if (canMoveUp) {
        moveUp(speed, onCollision: _cleanTargetMovementRandom);
      } else if (canMoveDown) {
        moveDown(speed, onCollision: _cleanTargetMovementRandom);
      } else {
        _cleanTargetMovementRandom();
      }
    }
  }

  void _cleanTargetMovementRandom() {
    _targetRandomMovement = Vector2.zero();
    idle();
  }
}
