import 'package:bonfire/bonfire.dart';
import 'package:flutter/widgets.dart';

/// API that handles movement per cell for a component.
///
/// The parent component must have a [Movement] mixin.
class MovePerCellApi {
  final Movement _comp;

  bool _pushPerCellEnabled = false;
  double _pushPerCellDuration = 0.5;
  Curve _pushPerCellCurve = Curves.decelerate;
  Vector2? _cellSize;
  bool _enabled = true;
  bool _moving = false;

  Vector2? _targetCellPosition;

  MovePerCellApi(this._comp);

  /// Whether movement per cell is enabled.
  bool get enabled => _enabled;

  /// The configured cell size. Falls back to the component size.
  Vector2 get cellSize => _cellSize ?? _comp.size;

  /// Sets up movement per cell behavior.
  void setup({
    bool? enabled,
    bool? pushPerCellEnabled,
    Vector2? cellSize,
    double? pushPerCellDuration,
    Curve? pushPerCellCurve,
  }) {
    _enabled = enabled ?? _enabled;
    _pushPerCellEnabled = pushPerCellEnabled ?? _pushPerCellEnabled;
    _cellSize = cellSize ?? _cellSize;
    _pushPerCellDuration = pushPerCellDuration ?? _pushPerCellDuration;
    _pushPerCellCurve = pushPerCellCurve ?? _pushPerCellCurve;
  }

  /// Updates the movement state.
  void update(double dt) {
    if (_enabled && _moving && _targetCellPosition != null) {
      if (_comp.position.distanceTo(_targetCellPosition!) < 1.0) {
        _comp.stop();
        _moving = false;
        _targetCellPosition = null;
      }
    }
  }

  /// Initiates a left movement by one cell.
  void moveLeft({double? speed, bool resetCrossAxis = false}) {
    _handleMove(
      () => _comp.moveLeft(speed: speed, resetCrossAxis: resetCrossAxis),
      Vector2(-cellSize.x, 0),
    );
  }

  /// Initiates a right movement by one cell.
  void moveRight({double? speed, bool resetCrossAxis = false}) {
    _handleMove(
      () => _comp.moveRight(speed: speed, resetCrossAxis: resetCrossAxis),
      Vector2(cellSize.x, 0),
    );
  }

  /// Initiates a down movement by one cell.
  void moveDown({double? speed, bool resetCrossAxis = false}) {
    _handleMove(
      () => _comp.moveDown(speed: speed, resetCrossAxis: resetCrossAxis),
      Vector2(0, cellSize.y),
    );
  }

  /// Initiates a up movement by one cell.
  void moveUp({double? speed, bool resetCrossAxis = false}) {
    _handleMove(
      () => _comp.moveUp(speed: speed, resetCrossAxis: resetCrossAxis),
      Vector2(0, -cellSize.y),
    );
  }

  void _handleMove(void Function() move, Vector2 targetOffset) {
    if (_enabled) {
      if (_moving) {
        return;
      }
      _targetCellPosition = _comp.position + targetOffset;
      _moving = true;
      move();
    } else {
      move();
    }
  }

  /// Initiates movement by angle restricted to the four main directions.
  void moveByAngle(double angle, {double? speed}) {
    if (_enabled) {
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
      _comp.moveByAngle(angle, speed: speed);
    }
  }
}
