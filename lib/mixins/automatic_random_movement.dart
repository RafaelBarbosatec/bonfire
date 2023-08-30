import 'dart:math';

import 'package:bonfire/bonfire.dart';

enum RandomMovementDirectionEnum {
  horizontally,
  vertically,
  horizontallyOrvertically,
  all
}

/// Mixin responsible for adding random movement like enemy walking through the scene
mixin AutomaticRandomMovement on Movement {
  Vector2? _targetRandomMovement;
  // ignore: constant_identifier_names
  static const _KEY_INTERVAL_KEEP_STOPPED = 'INTERVAL_RANDOM_MOVEMENT';

  late Random _random;

  bool get isVisibleReduction {
    if (hasGameRef) {
      return gameRef.isVisibleInCamera(this);
    }
    return false;
  }

  int _getTargetDistance(int minDistance, int maxDistance) {
    int randomInt = _random.nextInt(maxDistance);
    return randomInt < minDistance ? minDistance : randomInt;
  }

  /// Method that bo used in [update] method.
  void runRandomMovement(
    double dt, {
    bool runOnlyVisibleInCamera = true,
    double speed = 20,
    int maxDistance = 50,
    int minDistance = 0,

    /// milliseconds
    int timeKeepStopped = 2000,
    bool useAngle = false,
    RandomMovementDirectionEnum direction = RandomMovementDirectionEnum.all,
  }) {
    if (runOnlyVisibleInCamera && !isVisibleReduction) {
      return;
    }

    if (_targetRandomMovement == null) {
      if (checkInterval(_KEY_INTERVAL_KEEP_STOPPED, timeKeepStopped, dt)) {
        int randomX = 0, randomY = 0;

        switch (direction) {
          case RandomMovementDirectionEnum.horizontally:
            randomX = _getTargetDistance(minDistance, maxDistance);
            break;
          case RandomMovementDirectionEnum.vertically:
            randomY = _getTargetDistance(minDistance, maxDistance);
            break;
          case RandomMovementDirectionEnum.horizontallyOrvertically:
            if (_random.nextBool()) {
              randomX = _getTargetDistance(minDistance, maxDistance);
            } else {
              randomY = _getTargetDistance(minDistance, maxDistance);
            }
            break;
          case RandomMovementDirectionEnum.all:
            randomX = _getTargetDistance(minDistance, maxDistance);
            randomY = _getTargetDistance(minDistance, maxDistance);
            break;
        }

        int randomNegativeX = _random.nextBool() ? -1 : 1;
        int randomNegativeY = _random.nextBool() ? -1 : 1;
        _targetRandomMovement = position.translated(
          randomX.toDouble() * randomNegativeX,
          randomY.toDouble() * randomNegativeY,
        );
        if (useAngle) {
          angle = BonfireUtil.angleBetweenPoints(
            toAbsoluteRect().center.toVector2(),
            _targetRandomMovement!,
          );
        }
      }
    } else {
      double diffX = (_targetRandomMovement!.x - x).abs();
      double diffY = (_targetRandomMovement!.y - y).abs();

      bool canMoveX = diffX > speed;
      bool canMoveY = diffY > speed;

      bool canMoveLeft = false;
      bool canMoveRight = false;
      bool canMoveUp = false;
      bool canMoveDown = false;
      if (canMoveX) {
        if (_targetRandomMovement!.x > x) {
          canMoveRight = true;
        } else {
          canMoveLeft = true;
        }
      }
      if (canMoveY) {
        if (_targetRandomMovement!.y > y) {
          canMoveDown = true;
        } else {
          canMoveUp = true;
        }
      }
      if (useAngle) {
        if (canMoveX && canMoveY) {
          moveFromAngle(angle, speed: speed);
        } else {
          stopMove();
        }
      } else {
        if (canMoveLeft && canMoveUp) {
          moveUpLeft(speed: speed);
        } else if (canMoveLeft && canMoveDown) {
          moveDownLeft(speed: speed);
        } else if (canMoveRight && canMoveUp) {
          moveUpRight(speed: speed);
        } else if (canMoveRight && canMoveDown) {
          moveDownRight(speed: speed);
        } else if (canMoveRight) {
          moveRight(speed: speed);
        } else if (canMoveLeft) {
          moveLeft(speed: speed);
        } else if (canMoveUp) {
          moveUp(speed: speed);
        } else if (canMoveDown) {
          moveDown(speed: speed);
        } else {
          stopMove();
        }
      }
    }
  }

  @override
  void stopMove({bool forceIdle = false, bool isX = true, bool isY = true}) {
    super.stopMove(forceIdle: forceIdle, isX: isX, isY: isY);
    _targetRandomMovement = null;
    idle();
  }

  @override
  void setZeroVelocity({bool isX = true, bool isY = true}) {
    super.setZeroVelocity(isX: isX, isY: isY);
    stopMove();
  }

  @override
  void onMount() {
    _random = Random(Random().nextInt(1000));
    super.onMount();
  }
}
