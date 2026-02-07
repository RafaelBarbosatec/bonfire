import 'package:bonfire/bonfire.dart';
import 'package:flutter/widgets.dart';

mixin MovePerCell on Movement {
  bool _pushPerCellEnabled = false;
  double _pushPerCellDuration = 0.5;
  Curve _pushPerCellCurve = Curves.decelerate;
  Vector2? _cellSize;
  bool _perCellEnabled = true;
  bool _perCellMoving = false;

  Vector2? _targetCellPosition;

  void setupMovePerCell({
    bool? enabled,
    PushableFromEnum? pushableFrom,
    bool? pushPerCellEnabled,
    Vector2? cellSize,
    double? pushPerCellDuration,
    Curve? pushPerCellCurve,
  }) {
    _perCellEnabled = enabled ?? _perCellEnabled;
    _pushPerCellEnabled = pushPerCellEnabled ?? _pushPerCellEnabled;
    _cellSize = cellSize ?? _cellSize;
    _pushPerCellDuration = pushPerCellDuration ?? _pushPerCellDuration;
    _pushPerCellCurve = pushPerCellCurve ?? _pushPerCellCurve;
  }

  Vector2 get cellSize => _cellSize ?? size;

  @override
  void update(double dt) {
    if (_perCellEnabled && _perCellMoving) {
      if (_targetCellPosition != null) {
        if (position.distanceTo(_targetCellPosition!) < 1.0) {
          stop();
          _perCellMoving = false;
          _targetCellPosition = null;
        }
      }
    }
    super.update(dt);
  }

  @override
  void moveLeft({double? speed, bool resetCrossAxis = false}) {
    if (_perCellEnabled) {
      if (_perCellMoving) {
        return;
      }
      _targetCellPosition = position + Vector2(-cellSize.x, 0);
      _perCellMoving = true;
      super.moveLeft(speed: speed, resetCrossAxis: resetCrossAxis);
    } else {
      super.moveLeft(speed: speed, resetCrossAxis: resetCrossAxis);
    }
  }

  @override
  void moveRight({double? speed, bool resetCrossAxis = false}) {
    if (_perCellEnabled) {
      if (_perCellMoving) {
        return;
      }
      _targetCellPosition = position + Vector2(cellSize.x, 0);
      _perCellMoving = true;
      super.moveRight(speed: speed, resetCrossAxis: resetCrossAxis);
    } else {
      super.moveRight(speed: speed, resetCrossAxis: resetCrossAxis);
    }
  }

  @override
  void moveDown({double? speed, bool resetCrossAxis = false}) {
    if (_perCellEnabled) {
      if (_perCellMoving) {
        return;
      }
      _targetCellPosition = position + Vector2(0, cellSize.y);
      _perCellMoving = true;
      super.moveDown(speed: speed, resetCrossAxis: resetCrossAxis);
    } else {
      super.moveDown(speed: speed, resetCrossAxis: resetCrossAxis);
    }
  }

  @override
  void moveUp({double? speed, bool resetCrossAxis = false}) {
    if (_perCellEnabled) {
      if (_perCellMoving) {
        return;
      }
      _targetCellPosition = position + Vector2(0, -cellSize.y);
      _perCellMoving = true;
      super.moveUp(speed: speed, resetCrossAxis: resetCrossAxis);
    } else {
      super.moveUp(speed: speed, resetCrossAxis: resetCrossAxis);
    }
  }

  @override
  void moveByAngle(double angle, {double? speed}) {
    if (_perCellEnabled) {
      switch (BonfireUtil.getDirectionFromAngle(angle, directionSpace: 45)) {
        case Direction.left:
          moveLeft();
          break;
        case Direction.right:
          moveRight();
          break;
        case Direction.up:
          moveUp();
          break;
        case Direction.down:
          moveDown();
          break;
        default:
      }
    } else {
      super.moveByAngle(angle, speed: speed);
    }
  }

  @override
  void onGameMounted() {
    if (this is MovementByJoystick) {
      (this as MovementByJoystick).setupMovementByJoystick(
        startOnIdle: false,
        diagonalEnabled: false,
      );
    }
    super.onGameMounted();
  }
}
