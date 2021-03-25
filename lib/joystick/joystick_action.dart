import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/joystick/joystick_controller.dart';
import 'package:bonfire/util/assets_loader.dart';
import 'package:bonfire/util/vector2rect.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

enum JoystickActionAlign { TOP_LEFT, BOTTOM_LEFT, TOP_RIGHT, BOTTOM_RIGHT }

class JoystickAction {
  final dynamic actionId;
  Sprite sprite;
  Sprite spritePressed;
  Sprite spriteBackgroundDirection;
  final double sizeFactorBackgroundDirection;
  final double size;
  final EdgeInsets margin;
  final JoystickActionAlign align;
  final bool enableDirection;
  final Color color;
  final double opacityBackground;
  final double opacityKnob;

  double _sizeBackgroundDirection;

  int _pointer;
  Vector2Rect _rect;
  Vector2Rect _rectBackgroundDirection;
  bool _dragging = false;
  Sprite _spriteToRender;
  double _tileSize;
  Offset _dragPosition;
  Paint _paintBackground;
  Paint _paintAction;
  Paint _paintActionPressed;
  JoystickController _joystickController;
  bool isPressed = false;

  final _loader = AssetsLoader();

  JoystickAction({
    @required this.actionId,
    Future<Sprite> sprite,
    Future<Sprite> spritePressed,
    Future<Sprite> spriteBackgroundDirection,
    this.enableDirection = false,
    this.size = 50,
    this.sizeFactorBackgroundDirection = 1.5,
    this.margin = EdgeInsets.zero,
    this.color = Colors.blueGrey,
    this.align = JoystickActionAlign.BOTTOM_RIGHT,
    this.opacityBackground = 0.5,
    this.opacityKnob = 0.8,
  }) {
    _loader.add(AssetToLoad(sprite, (value) {
      this.sprite = value;
    }));
    _loader.add(AssetToLoad(spritePressed, (value) {
      this.spritePressed = value;
    }));
    _loader.add(AssetToLoad(spriteBackgroundDirection, (value) {
      this.spriteBackgroundDirection = value;
    }));
    _sizeBackgroundDirection = sizeFactorBackgroundDirection * size;
    _tileSize = _sizeBackgroundDirection / 2;
  }

  void initialize(Vector2 _screenSize, JoystickController joystickController) {
    _joystickController = joystickController;
    double radius = size / 2;
    double dx = 0, dy = 0;
    switch (align) {
      case JoystickActionAlign.TOP_LEFT:
        dx = margin.left + radius;
        dy = margin.top + radius;
        break;
      case JoystickActionAlign.BOTTOM_LEFT:
        dx = margin.left + radius;
        dy = _screenSize.y - (margin.bottom + radius);
        break;
      case JoystickActionAlign.TOP_RIGHT:
        dx = _screenSize.x - (margin.right + radius);
        dy = margin.top + radius;
        break;
      case JoystickActionAlign.BOTTOM_RIGHT:
        dx = _screenSize.x - (margin.right + radius);
        dy = _screenSize.y - (margin.bottom + radius);
        break;
    }
    _rect = Rect.fromCircle(
      center: Offset(dx, dy),
      radius: radius,
    ).toVector2Rect();

    _rectBackgroundDirection = Rect.fromCircle(
      center: Offset(dx, dy),
      radius: _sizeBackgroundDirection / 2,
    ).toVector2Rect();

    _dragPosition = _rect.center;
  }

  void render(Canvas c) {
    if (_rectBackgroundDirection != null && _dragging && enableDirection) {
      if (spriteBackgroundDirection == null) {
        double radiusBackground = _rectBackgroundDirection.rect.width / 2;
        c.drawCircle(
          Offset(
            _rectBackgroundDirection.rect.left + radiusBackground,
            _rectBackgroundDirection.rect.top + radiusBackground,
          ),
          radiusBackground,
          _paintBackground,
        );
      } else {
        spriteBackgroundDirection.renderFromVector2Rect(
          c,
          _rectBackgroundDirection,
        );
      }
    }

    if (_spriteToRender != null) {
      if (_rect != null)
        _spriteToRender.render(
          c,
          position: _rect.position,
          size: _rect.size,
        );
    } else {
      double radiusAction = _rect.rect.width / 2;
      c.drawCircle(
        Offset(
          _rect.rect.left + radiusAction,
          _rect.rect.top + radiusAction,
        ),
        radiusAction,
        isPressed ? _paintActionPressed : _paintAction,
      );
    }
  }

  void update(double dt) {
    if (_dragging) {
      double _radAngle = atan2(
        _dragPosition.dy - _rectBackgroundDirection.center.dy,
        _dragPosition.dx - _rectBackgroundDirection.center.dx,
      );

      // Distance between the center of joystick background & drag position
      Vector2 centerPosition = _rectBackgroundDirection.center.toVector2();
      Vector2 dragPosition = _dragPosition.toVector2();
      double dist = centerPosition.distanceTo(dragPosition);

      // The maximum distance for the knob position the edge of
      // the background + half of its own size. The knob can wander in the
      // background image, but not outside.
      dist = min(dist, _tileSize);

      // Calculation the knob position
      double nextX = dist * cos(_radAngle);
      double nextY = dist * sin(_radAngle);
      Offset nextPoint = Offset(nextX, nextY);

      Offset diff = Offset(
            _rectBackgroundDirection.center.dx + nextPoint.dx,
            _rectBackgroundDirection.center.dy + nextPoint.dy,
          ) -
          _rect.center;
      _rect = _rect.shift(diff);

      double _intensity = dist / _tileSize;

      _joystickController.joystickAction(
        JoystickActionEvent(
          id: actionId,
          event: ActionEvent.MOVE,
          intensity: _intensity,
          radAngle: _radAngle,
        ),
      );
    } else {
      if (_rect != null) {
        Offset diff = _dragPosition - _rect.center;
        _rect = _rect.shift(diff);
      }
    }
  }

  void onDragStart(int pointer, Offset localPosition) {
    if (!_dragging && _rect != null && _rect.rect.contains(localPosition)) {
      _pointer = pointer;
      if (enableDirection) {
        _dragPosition = localPosition;
        _dragging = true;
      }
      _joystickController.joystickAction(
        JoystickActionEvent(
          id: actionId,
          event: ActionEvent.DOWN,
        ),
      );
      pressed();
    }
  }

  void onDragUpdate(int pointer, Offset localPosition) {
    if (pointer == _pointer) {
      if (_dragging) {
        _dragPosition = localPosition;
      }
    }
  }

  void onDragCancel(int pointer) {
    if (pointer == _pointer) {
      _dragging = false;
      _dragPosition = _rectBackgroundDirection.center;
      unPressed();
    }
  }

  void onDragEnd(int pointer) {
    if (pointer == _pointer) {
      _dragging = false;
      _dragPosition = _rectBackgroundDirection.center;
      _joystickController.joystickAction(
        JoystickActionEvent(
          id: actionId,
          event: ActionEvent.UP,
        ),
      );
      unPressed();
    }
  }

  void onTapUp(int pointer) {
    if (pointer == _pointer) {
      _joystickController.joystickAction(
        JoystickActionEvent(
          id: actionId,
          event: ActionEvent.UP,
        ),
      );
      unPressed();
    }
  }

  void onTapDown(int pointer, Offset localPosition) {
    if (_rect != null && _rect.rect.contains(localPosition)) {
      _pointer = pointer;
      _joystickController.joystickAction(
        JoystickActionEvent(
          id: actionId,
          event: ActionEvent.DOWN,
        ),
      );
      pressed();
    }
  }

  void onTapCancel(int pointer) {
    if (pointer == _pointer) {
      unPressed();
    }
  }

  void pressed() {
    isPressed = true;
    if (spritePressed != null) {
      _spriteToRender = spritePressed;
    }
  }

  void unPressed() {
    isPressed = false;
    _spriteToRender = sprite;
  }

  Future<void> onLoad() async {
    await _loader.load();

    _spriteToRender = sprite;

    if (spriteBackgroundDirection == null) {
      _paintBackground = Paint()
        ..color = color.withOpacity(opacityBackground)
        ..style = PaintingStyle.fill;
    }

    if (sprite == null) {
      _paintAction = Paint()
        ..color = color.withOpacity(opacityKnob)
        ..style = PaintingStyle.fill;
    }

    if (spritePressed == null) {
      _paintActionPressed = Paint()
        ..color = color.withOpacity(opacityBackground)
        ..style = PaintingStyle.fill;
    }
  }
}
