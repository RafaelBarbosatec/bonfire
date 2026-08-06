import 'dart:math';

import 'package:bonfire/bonfire.dart';

/// Defines which directions are allowed for random movement.
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

/// Callback fired when random movement starts.
typedef OnRandomMovementStartCallback = void Function(Direction direction);

/// Callback fired when random movement stops.
typedef OnRandomMovementStopCallback = void Function();

/// API responsible for adding random movement behavior to a component.
///
/// The parent component must have a [Movement] mixin.
class RandomMovementApi {
  final Movement comp;

  static const String _intervalKeepStoppedKey = 'INTERVAL_RANDOM_MOVEMENT';

  final Random _random;

  double? _distanceToArrived;
  Direction _currentDirection = Direction.left;
  Vector2 _originPosition = Vector2.zero();
  double _travelledDistance = 0;

  /// Area where the random movement will be made.
  ShapeHitbox? area;

  final List<OnRandomMovementStartCallback> _onStartMoveCallbacks = [];
  final List<OnRandomMovementStopCallback> _onStopMoveCallbacks = [];

  RandomMovementApi(this.comp) : _random = Random(Random().nextInt(1000));

  /// Registers a callback fired when random movement starts.
  void onStartMoveListener(OnRandomMovementStartCallback callback) {
    _onStartMoveCallbacks.add(callback);
  }

  /// Registers a callback fired when random movement stops.
  void onStopMoveListener(OnRandomMovementStopCallback callback) {
    _onStopMoveCallbacks.add(callback);
  }

  /// Executes random movement. Should be called inside the component's
  /// [update] method.
  void update(
    double dt, {
    double? speed,
    double maxDistance = 50,
    double minDistance = 25,

    /// milliseconds
    int timeKeepStopped = 2000,
    bool updateAngle = false,
    bool checkDirectionWithRayCast = false,
    RandomMovementDirections directions = RandomMovementDirections.all,
  }) {
    if (_distanceToArrived == null) {
      if (comp.checkInterval(_intervalKeepStoppedKey, timeKeepStopped, dt)) {
        final target = _getTarget(
          minDistance,
          maxDistance,
          checkDirectionWithRayCast,
          directions,
        );
        if (target == null) {
          _stop();
          return;
        }
        _currentDirection = target.direction;
        _distanceToArrived = target.distance;
        _originPosition = comp.absoluteCenter.clone();
        _notifyStartMove(_currentDirection);
      }
    } else {
      _travelledDistance = comp.absoluteCenter.distanceTo(_originPosition);
      final isCanMove = comp.canMove(_currentDirection, displacement: speed);
      if (_travelledDistance >= _distanceToArrived! || !isCanMove) {
        _stop();
        return;
      }

      comp.moveFromDirection(_currentDirection, speed: speed);
      if (updateAngle) {
        comp.angle = _currentDirection.toRadians();
      }
    }
  }

  void _stop() {
    _notifyStopMove();
    _distanceToArrived = null;
    _originPosition = Vector2.zero();
    comp.stop();
  }

  double _getDistance(double minDistance, double maxDistance) {
    final diffDistance = maxDistance - minDistance;
    return minDistance + _random.nextDouble() * diffDistance;
  }

  Direction _getDirection(RandomMovementDirections directions) {
    final randomInt = _random.nextInt(directions.length);
    return directions.values[randomInt];
  }

  Vector2 _getTargetPosition(
    Direction currentDirection,
    double? distanceToArrived,
  ) {
    return comp.absoluteCenter +
        currentDirection.toVector2() * distanceToArrived!;
  }

  _RandomPositionTarget? _getTarget(
    double minDistance,
    double maxDistance,
    bool checkDirectionWithRayCast,
    RandomMovementDirections directions,
  ) {
    var index = 0;
    while (index < 100) {
      final distance = _getDistance(minDistance, maxDistance);
      final direction = _getDirection(directions);
      final targetPosition = _getTargetPosition(direction, distance);
      var isRaycastOk = true;

      if (checkDirectionWithRayCast) {
        isRaycastOk = comp.canMove(
          _currentDirection,
          displacement: _distanceToArrived,
        );
      }

      if (area != null) {
        final insideArea = area!.containsPoint(targetPosition);
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

  void _notifyStartMove(Direction direction) {
    for (final callback in _onStartMoveCallbacks) {
      callback(direction);
    }
  }

  void _notifyStopMove() {
    for (final callback in _onStopMoveCallbacks) {
      callback();
    }
  }

  /// Releases all registered callbacks.
  void dispose() {
    _onStartMoveCallbacks.clear();
    _onStopMoveCallbacks.clear();
  }
}

class _RandomPositionTarget {
  final Vector2 position;
  final Direction direction;
  final double distance;

  _RandomPositionTarget({
    required this.position,
    required this.direction,
    required this.distance,
  });
}
