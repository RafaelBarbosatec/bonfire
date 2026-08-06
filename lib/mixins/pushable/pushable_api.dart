import 'package:bonfire/bonfire.dart';
import 'package:flutter/widgets.dart';

/// Defines from which type of component the push can happen.
// ignore: constant_identifier_names
enum PushableFromEnum { ENEMY, PLAYER_OR_ALLY, ALL }

/// Callback used to decide if the component accepts being pushed by [component].
typedef OnPushCallback = bool Function(GameComponent component);

/// API that handles pushable behavior for a component.
///
/// To use this behavior the parent component must have a [Movement] mixin.
class PushableApi {
  final Movement comp;

  bool _enabled = true;
  PushableFromEnum _pushableFrom = PushableFromEnum.ALL;
  bool _pushPerCellEnabled = false;
  double _pushPerCellDuration = 0.5;
  Curve _pushPerCellCurve = Curves.decelerate;
  Vector2? _cellSize;
  bool _perCellMoving = false;

  OnPushCallback? _onPushCallback;

  PushableApi(this.comp);

  /// Whether the pushable behavior is enabled.
  bool get enabled => _enabled;

  /// Sets up pushable behavior.
  void setup({
    bool? enabled,
    PushableFromEnum? pushableFrom,
    bool? pushPerCellEnabled,
    Vector2? cellSize,
    double? pushPerCellDuration,
    Curve? pushPerCellCurve,
  }) {
    _enabled = enabled ?? _enabled;
    _pushableFrom = pushableFrom ?? _pushableFrom;
    _pushPerCellEnabled = pushPerCellEnabled ?? _pushPerCellEnabled;
    _cellSize = cellSize ?? _cellSize;
    _pushPerCellDuration = pushPerCellDuration ?? _pushPerCellDuration;
    _pushPerCellCurve = pushPerCellCurve ?? _pushPerCellCurve;
  }

  /// Registers a callback that decides if the component can be pushed.
  void onPushListener(OnPushCallback callback) {
    _onPushCallback = callback;
  }

  /// Handles collision from another component and applies push if needed.
  void handleCollision(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    if (!_enabled || other is WithSensor) {
      return;
    }

    if (other is GameComponent) {
      switch (_pushableFrom) {
        case PushableFromEnum.ENEMY:
          if (other is! Enemy) {
            return;
          }
        case PushableFromEnum.PLAYER_OR_ALLY:
          if (other is! Player && other is! Ally) {
            return;
          }
        case PushableFromEnum.ALL:
      }

      final component = other;
      if (component is Movement && _canPush(component)) {
        final displacement = comp.rectCollision.centerVector2 -
            component.rectCollision.centerVector2;
        if (_pushPerCellEnabled) {
          _movePerCell(component, displacement);
        } else {
          _move(displacement);
        }
      }
    }
  }

  bool _canPush(GameComponent component) {
    return _onPushCallback?.call(component) ?? true;
  }

  void _move(Vector2 displacement) {
    if (displacement.x.abs() > displacement.y.abs()) {
      if (displacement.x < 0) {
        comp.moveLeft();
      } else {
        comp.moveRight();
      }
    } else {
      if (displacement.y < 0) {
        comp.moveUp();
      } else {
        comp.moveDown();
      }
    }
  }

  void _movePerCell(Movement component, Vector2 displacement) {
    if (_perCellMoving) {
      return;
    }
    final cellSize = _cellSize ?? comp.size;
    _perCellMoving = true;
    final Vector2 offset;
    if (displacement.x.abs() > displacement.y.abs()) {
      offset = displacement.x < 0
          ? Vector2(-cellSize.x, 0)
          : Vector2(cellSize.x, 0);
    } else {
      offset = displacement.y < 0
          ? Vector2(0, -cellSize.y)
          : Vector2(0, cellSize.y);
    }

    comp.add(
      MoveEffect.by(
        offset,
        EffectController(
          duration: _pushPerCellDuration,
          curve: _pushPerCellCurve,
        ),
        onComplete: () => _perCellMoving = false,
      ),
    );
  }
}
