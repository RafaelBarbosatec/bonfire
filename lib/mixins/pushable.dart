import 'package:bonfire/bonfire.dart';
import 'package:flutter/widgets.dart';

///
/// Created by
///
/// ─▄▀─▄▀
/// ──▀──▀
/// █▀▀▀▀▀█▄
/// █░░░░░█─█
/// ▀▄▄▄▄▄▀▀
///
/// Rafaelbarbosatec
/// on 23/12/21

/// This mixin give to the component the pushable behavior.
/// To use this mixin the Component must have a `Movement` mixin.
mixin Pushable on Movement {
  bool _enablePushable = true;
  PushableFromEnum _pushbleFrom = PushableFromEnum.ALL;
  bool _pushPerCellEnabled = false;
  double _pushPerCellDuration = 0.5;
  Curve _pushPerCellCurve = Curves.decelerate;
  Vector2? _cellSize;
  bool _percellMoving = false;

  void setupPushable({
    bool? enabled,
    PushableFromEnum? pushableFrom,
    bool? pushPerCellEnabled,
    Vector2? cellSize,
    double? pushPerCellDuration,
    Curve? pushPerCellCurve,
  }) {
    _enablePushable = enabled ?? _enablePushable;
    _pushbleFrom = pushableFrom ?? _pushbleFrom;
    _pushPerCellEnabled = pushPerCellEnabled ?? _pushPerCellEnabled;
    _cellSize = cellSize ?? _cellSize;
    _pushPerCellDuration = pushPerCellDuration ?? _pushPerCellDuration;
    _pushPerCellCurve = pushPerCellCurve ?? _pushPerCellCurve;
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (_enablePushable && other is! Sensor) {
      if (other is GameComponent) {
        switch (_pushbleFrom) {
          case PushableFromEnum.ENEMY:
            if (other is! Enemy) {
              return;
            }
          case PushableFromEnum.PLAYER_OR_ALLY:
            if (other is! Player || other is! Ally) {
              return;
            }
          case PushableFromEnum.ALL:
        }
        final component = other;
        if (component is Movement && onPush(component)) {
          final displacement = rectCollision.centerVector2 -
              component.rectCollision.centerVector2;
          if (_pushPerCellEnabled) {
            _movePercell(component, displacement);
          } else {
            _move(component, displacement);
          }
        }
      }
    }
  }

  /// Returning true if the component is pushable, false otherwise.
  bool onPush(GameComponent component) {
    return true;
  }

  void _move(Movement component, Vector2 displacement) {
    if (displacement.x.abs() > displacement.y.abs()) {
      if (displacement.x < 0) {
        if (this is HandleForces) {
          moveLeft(speed: component.speed / (this as HandleForces).mass);
        } else {
          moveLeftOnce();
        }
      } else {
        if (this is HandleForces) {
          moveRight(speed: component.speed / (this as HandleForces).mass);
        } else {
          moveRightOnce();
        }
      }
    } else {
      if (displacement.y < 0) {
        if (this is HandleForces) {
          moveUp(speed: component.speed / (this as HandleForces).mass);
        } else {
          moveUpOnce();
        }
      } else {
        if (this is HandleForces) {
          moveDown(speed: component.speed / (this as HandleForces).mass);
        } else {
          moveDownOnce();
        }
      }
    }
  }

  void _movePercell(Movement component, Vector2 displacement) {
    if (_percellMoving) {
      return;
    }
    final cellSize = _cellSize ?? size;
    _percellMoving = true;
    if (displacement.x.abs() > displacement.y.abs()) {
      if (displacement.x < 0) {
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
      }
    } else {
      if (displacement.y < 0) {
        add(
          MoveEffect.by(
            Vector2(0, -cellSize.y),
            EffectController(
              duration: _pushPerCellDuration,
              curve: _pushPerCellCurve,
            ),
            onComplete: _perCeelMovecomplete,
          ),
        );
      } else {
        add(
          MoveEffect.by(
            Vector2(0, cellSize.y),
            EffectController(
              duration: _pushPerCellDuration,
              curve: _pushPerCellCurve,
            ),
            onComplete: _perCeelMovecomplete,
          ),
        );
      }
    }
  }

  void _perCeelMovecomplete() {
    _percellMoving = false;
  }
}

// ignore: constant_identifier_names
enum PushableFromEnum { ENEMY, PLAYER_OR_ALLY, ALL }
