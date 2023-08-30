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
    randomInt = randomInt < minDistance ? minDistance : randomInt;
    return randomInt * (_random.nextBool() ? -1 : 1);
  }

  /// Method that bo used in [update] method.
  void runRandomMovement(
    double dt, {
    bool runOnlyVisibleInCamera = true,
    double? speed,
    int maxDistance = 50,
    int minDistance = 25,

    /// milliseconds
    int timeKeepStopped = 2000,
    bool updateAngle = false,
    bool checkPositionWithRaycast = false,
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

        _targetRandomMovement = position.translated(
          randomX.toDouble(),
          randomY.toDouble(),
        );

        if (checkPositionWithRaycast) {
          final direct = (_targetRandomMovement! - position).normalized();
          final result = raycast(
            direct,
            origin: position,
            maxDistance: position.distanceTo(_targetRandomMovement!),
          );
          if (result?.hitbox != null) {
            _targetRandomMovement = null;
            tickInterval(_KEY_INTERVAL_KEEP_STOPPED);
          }
        }
      }
    } else {
      if (!moveToPosition(
        _targetRandomMovement!,
        speed: speed,
        useCenter: false,
      )) {
        stopMove();
      }
      if (updateAngle) {
        angle = lastDirection.toRadians();
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
