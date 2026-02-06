import 'package:bonfire/bonfire.dart';
import 'package:flutter/widgets.dart';

mixin MovePerCell on Movement {
  bool _pushPerCellEnabled = false;
  double _pushPerCellDuration = 0.5;
  Curve _pushPerCellCurve = Curves.decelerate;
  Vector2? _cellSize;
  bool _perCellEnabled = true;
  bool _perCellMoving = false;

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
  void moveLeft({double? speed, bool resetCrossAxis = false}) {
    if (_perCellEnabled) {
      if (_perCellMoving) {
        return;
      }
      _perCellMoving = true;
      add(
        MoveEffect.by(
          Vector2(-cellSize.x, 0),
          EffectController(
            duration: _pushPerCellDuration,
            curve: _pushPerCellCurve,
          ),
          onComplete: _perCeelMovecomplete,
        ),
      );
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
      _perCellMoving = true;
      add(
        MoveEffect.by(
          Vector2(cellSize.x, 0),
          EffectController(
            duration: _pushPerCellDuration,
            curve: _pushPerCellCurve,
          ),
          onComplete: _perCeelMovecomplete,
        ),
      );
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
      _perCellMoving = true;
      add(
        MoveEffect.by(
          Vector2(0, cellSize.x),
          EffectController(
            duration: _pushPerCellDuration,
            curve: _pushPerCellCurve,
          ),
          onComplete: _perCeelMovecomplete,
        ),
      );
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
      _perCellMoving = true;
      add(
        MoveEffect.by(
          Vector2(0, -cellSize.x),
          EffectController(
            duration: _pushPerCellDuration,
            curve: _pushPerCellCurve,
          ),
          onComplete: _perCeelMovecomplete,
        ),
      );
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

  void _perCeelMovecomplete() {
    _perCellMoving = false;
  }
}
