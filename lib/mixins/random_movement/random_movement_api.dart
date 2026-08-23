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
  final Movement _comp;

  late Random _random;

  double? _distanceToArrived;
  Direction _currentDirection = Direction.left;
  Vector2 _originPosition = Vector2.zero();
  double _travelledDistance = 0;

  /// Area where the random movement will be made.
  ShapeHitbox? area;

  final List<OnRandomMovementStartCallback> _onStartMoveCallbacks = [];
  final List<OnRandomMovementStopCallback> _onStopMoveCallbacks = [];

  IntervalTick _intervalTick = IntervalTick(
    2000,
  );

  double? _speed;
  double _maxDistance = 50;
  double _minDistance = 25;
  bool _updateAngle = false;
  bool _checkDirectionWithRayCast = false;
  RandomMovementDirections _directions = RandomMovementDirections.all;

  RandomMovementApi(this._comp) {
    _random = Random(Random().nextInt(1000));
  }

  void setup({
    double? speed,
    double? maxDistance,
    double? minDistance,

    /// milliseconds
    int? timeKeepStopped,
    bool? updateAngle,
    bool? checkDirectionWithRayCast,
    RandomMovementDirections? directions,
  }) {
    if (speed != null) {
      _speed = speed;
    }
    if (maxDistance != null) {
      _maxDistance = maxDistance;
    }
    if (minDistance != null) {
      _minDistance = minDistance;
    }
    if (timeKeepStopped != null) {
      _intervalTick = IntervalTick(
        timeKeepStopped,
      );
    }
    if (updateAngle != null) {
      _updateAngle = updateAngle;
    }
    if (checkDirectionWithRayCast != null) {
      _checkDirectionWithRayCast = checkDirectionWithRayCast;
    }
    if (directions != null) {
      _directions = directions;
    }
  }

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
  void run(
    double dt,
  ) {
    if (_distanceToArrived == null) {
      final tick = _intervalTick.update(
        dt,
      );
      if (tick) {
        final target = _getTarget(
          _minDistance,
          _maxDistance,
          _checkDirectionWithRayCast,
          _directions,
        );
        if (target == null) {
          _stop();
          return;
        }
        _currentDirection = target.direction;
        _distanceToArrived = target.distance;
        _originPosition = _comp.absoluteCenter.clone();
        _notifyStartMove(_currentDirection);
      }
    } else {
      _travelledDistance = _comp.absoluteCenter.distanceTo(_originPosition);
      final isCanMove = _comp.canMove(_currentDirection, displacement: _speed);
      if (_travelledDistance >= _distanceToArrived! || !isCanMove) {
        _stop();
        return;
      }

      _comp.moveFromDirection(_currentDirection, speed: _speed);
      if (_updateAngle) {
        _comp.angle = _currentDirection.toRadians();
      }
    }
  }

  void _stop() {
    _notifyStopMove();
    _distanceToArrived = null;
    _originPosition = Vector2.zero();
    _comp.stop();
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
    return _comp.absoluteCenter +
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
        isRaycastOk = _comp.canMove(
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
