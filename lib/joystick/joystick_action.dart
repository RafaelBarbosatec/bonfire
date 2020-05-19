import 'dart:math';

import 'package:bonfire/joystick/joystick_controller.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

enum JoystickActionAlign { TOP_LEFT, BOTTOM_LEFT, TOP_RIGHT, BOTTOM_RIGHT }

class JoystickAction {
  final int actionId;
  final String pathSprite;
  final String pathSpritePressed;
  final double size;
  double sizeBackgroundDirection;
  final EdgeInsets margin;
  final JoystickActionAlign align;
  final bool enableDirection;
  final Color colorBackgroundDirection;

  int _pointerDragging;
  Rect _rect;
  Rect _rectBackgroundDirection;
  bool _dragging = false;
  Sprite _sprite;
  double _backgroundAspectRatio = 1;
  double _tileSize;
  Offset _dragPosition;
  Paint _paintBackground;
  JoystickListener _joystickListener;

  JoystickAction({
    @required this.actionId,
    @required this.pathSprite,
    this.pathSpritePressed,
    this.enableDirection = false,
    this.size = 20,
    this.sizeBackgroundDirection,
    this.margin = EdgeInsets.zero,
    this.colorBackgroundDirection = Colors.blueGrey,
    this.align = JoystickActionAlign.BOTTOM_RIGHT,
  }) {
    _sprite = Sprite(pathSprite);
    sizeBackgroundDirection = sizeBackgroundDirection ?? size * 1.5;
    _tileSize = sizeBackgroundDirection;
  }

  void initialize(Size _screenSize, JoystickListener joystickListener) {
    _joystickListener = joystickListener;
    double radius = size / 2;
    double dx = 0, dy = 0;
    switch (align) {
      case JoystickActionAlign.TOP_LEFT:
        dx = margin.left + radius;
        dy = margin.top + radius;
        break;
      case JoystickActionAlign.BOTTOM_LEFT:
        dx = margin.left + radius;
        dy = _screenSize.height - (margin.bottom + radius);
        break;
      case JoystickActionAlign.TOP_RIGHT:
        dx = _screenSize.width - (margin.right + radius);
        dy = margin.top + radius;
        break;
      case JoystickActionAlign.BOTTOM_RIGHT:
        dx = _screenSize.width - (margin.right + radius);
        dy = _screenSize.height - (margin.bottom + radius);
        break;
    }
    _rect = Rect.fromCircle(
      center: Offset(dx, dy),
      radius: radius,
    );
    _rectBackgroundDirection = Rect.fromCircle(
      center: Offset(dx, dy),
      radius: sizeBackgroundDirection / 2,
    );
    _paintBackground = Paint()
      ..color = colorBackgroundDirection.withOpacity(0.5)
      ..style = PaintingStyle.fill;
    _dragPosition = _rect.center;
  }

  void render(Canvas c) {
    if (_rectBackgroundDirection != null && _dragging && enableDirection) {
      double radiusBackground = _rectBackgroundDirection.width / 2;
      c.drawCircle(
        Offset(
          _rectBackgroundDirection.left + radiusBackground,
          _rectBackgroundDirection.top + radiusBackground,
        ),
        radiusBackground,
        _paintBackground,
      );
    }
    if (_rect != null) _sprite.renderRect(c, _rect);
  }

  void update(double dt) {
    if (_dragging) {
      double _radAngle = atan2(
        _dragPosition.dy - _rectBackgroundDirection.center.dy,
        _dragPosition.dx - _rectBackgroundDirection.center.dx,
      );

      // Distance between the center of joystick background & drag position
      Point p = Point(
        _rectBackgroundDirection.center.dx,
        _rectBackgroundDirection.center.dy,
      );
      double dist = p.distanceTo(Point(_dragPosition.dx, _dragPosition.dy));

      // The maximum distance for the knob position the edge of
      // the background + half of its own size. The knob can wander in the
      // background image, but not outside.
      dist = dist < (_tileSize * _backgroundAspectRatio / 3)
          ? dist
          : (_tileSize * _backgroundAspectRatio / 3);

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

      double _intensity = dist / (_tileSize * _backgroundAspectRatio / 3);

      _joystickListener.joystickAction(
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

  void actionDown(int pointer, Offset localPosition) {
    if (!_dragging && _rect.contains(localPosition)) {
      _pointerDragging = pointer;
      if (enableDirection) {
        _dragPosition = localPosition;
        _dragging = true;
      }
      _joystickListener.joystickAction(
        JoystickActionEvent(
          id: actionId,
          event: ActionEvent.DOWN,
        ),
      );
      pressed();
    }
  }

  void actionMove(int pointer, Offset localPosition) {
    if (pointer == _pointerDragging) {
      if (_dragging) {
        _dragPosition = localPosition;
      }
    }
  }

  void actionUp(int pointer) {
    if (pointer == _pointerDragging) {
      _dragging = false;
      _dragPosition = _rectBackgroundDirection.center;
      _joystickListener.joystickAction(
        JoystickActionEvent(
          id: actionId,
          event: ActionEvent.UP,
        ),
      );
      unPressed();
    }
  }

  void pressed() {
    if (pathSpritePressed != null) {
      _sprite = Sprite(pathSpritePressed);
    }
  }

  void unPressed() {
    _sprite = Sprite(pathSprite);
  }
}
