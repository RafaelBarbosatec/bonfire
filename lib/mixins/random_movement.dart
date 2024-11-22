import 'dart:math';

import 'package:bonfire/bonfire.dart';

class RandomMovementDirections {
  final List<Direction> values;

  int get length => values.length;

  const RandomMovementDirections({required this.values});

  static const RandomMovementDirections all = RandomMovementDirections(
    values: Direction.values,
  );

  static const RandomMovementDirections vertically = RandomMovementDirections(
    values: [Direction.up, Direction.down],
  );

  static const RandomMovementDirections horizontally = RandomMovementDirections(
    values: [Direction.left, Direction.right],
  );

  static const RandomMovementDirections withoutDiagonal =
      RandomMovementDirections(
    values: [
      Direction.left,
      Direction.right,
      Direction.up,
      Direction.down,
    ],
  );
}

/// Mixin responsible for adding random movement like enemy walking through the scene
mixin RandomMovement on Movement {
  // ignore: constant_identifier_names
  static const _KEY_INTERVAL_KEEP_STOPPED = 'INTERVAL_RANDOM_MOVEMENT';

  Function(Direction direction)? _onStartMove;
  Function()? _onStopMove;

  late Random _random;

  double? _distanceToArrived;
  Direction _currentDirection = Direction.left;
  Vector2 _originPosition = Vector2.zero();

  double _travelledDistance = 0;

  // Area where the random movement will be made
  ShapeHitbox? randomMovementArea;

  /// Method that bo used in [update] method.
  void runRandomMovement(
    double dt, {
    double? speed,
    double maxDistance = 50,
    double minDistance = 25,

    /// milliseconds
    int timeKeepStopped = 2000,
    bool updateAngle = false,
    bool checkDirectionWithRayCast = false,
    RandomMovementDirections directions = RandomMovementDirections.all,
    Function(Direction direction)? onStartMove,
    Function()? onStopMove,
  }) {
    _onStartMove = onStartMove;
    _onStopMove = onStopMove;

    if (_distanceToArrived == null) {
      if (checkInterval(_KEY_INTERVAL_KEEP_STOPPED, timeKeepStopped, dt)) {
        final target = _getTarget(
          minDistance,
          maxDistance,
          checkDirectionWithRayCast,
        );
        if (target == null) {
          _stop();
          return;
        }
        _currentDirection = target.direction;
        _distanceToArrived = target.distance;
        _originPosition = absoluteCenter.clone();
        _onStartMove?.call(_currentDirection);
      }
    } else {
      _travelledDistance = absoluteCenter.distanceTo(_originPosition);
      final isCanMove = canMove(_currentDirection, displacement: speed);
      if (_travelledDistance >= _distanceToArrived! || !isCanMove) {
        _stop();
        return;
      }

      moveFromDirection(_currentDirection, speed: speed);
      if (updateAngle) {
        angle = _currentDirection.toRadians();
      }
    }
  }

  @override
  void correctPositionFromCollision(Vector2 position) {
    super.correctPositionFromCollision(position);
    if (this is Jumper) {
      if ((this is BlockMovementCollision)) {
        final isV = (this as BlockMovementCollision)
                .lastCollisionData
                ?.direction
                .isVertical ==
            true;
        if (isV) {
          return;
        }
      }
    }
    _stop();
  }

  void _stop() {
    _onStopMove?.call();
    _onStopMove = null;
    _onStartMove = null;
    _distanceToArrived = null;
    _originPosition = Vector2.zero();
    stopMove();
  }

  @override
  void onMount() {
    _random = Random(Random().nextInt(1000));
    super.onMount();
  }

  double _getDistance(double minDistance, double maxDistance) {
    final diffDistane = maxDistance - minDistance;
    return minDistance + _random.nextDouble() * diffDistane;
  }

  Direction _getDirection(RandomMovementDirections directions) {
    final randomInt = _random.nextInt(directions.length);
    return directions.values[randomInt];
  }

  Vector2 _getTargetPosition(
    Direction currentDirection,
    double? distanceToArrived,
  ) {
    return absoluteCenter + currentDirection.toVector2() * distanceToArrived!;
  }

  _RandomPositionTarget? _getTarget(
    double minDistance,
    double maxDistance,
    bool checkDirectionWithRayCast,
  ) {
    int index = 0;
    while (index < 100) {
      final distance = _getDistance(minDistance, maxDistance);
      final direction = _getDirection(RandomMovementDirections.all);
      final targetPosition = _getTargetPosition(direction, distance);
      bool isRaycastOk = true;

      if (checkDirectionWithRayCast) {
        isRaycastOk = canMove(
          _currentDirection,
          displacement: _distanceToArrived,
        );
      }

      if (randomMovementArea != null) {
        final insideArea = randomMovementArea!.containsPoint(
          targetPosition,
        );
        if (insideArea && isRaycastOk) {
          return _RandomPositionTarget(
            position: targetPosition,
            direction: direction,
            distance: distance,
          );
        }
      } else if (isRaycastOk) {
        return _RandomPositionTarget(
          position: targetPosition,
          direction: direction,
          distance: distance,
        );
      }

      index++;
    }
    return null;
  }
}

class _RandomPositionTarget {
  final Vector2 position;
  final Direction direction;
  final double distance;

  _RandomPositionTarget(
      {required this.position,
      required this.direction,
      required this.distance});
}
