import 'dart:math';

import 'package:bonfire/joystick/joystick_action.dart';
import 'package:bonfire/joystick/joystick_controller.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Joystick extends JoystickController {
  double _backgroundAspectRatio = 2.2;
  Rect _backgroundRect;
  Sprite _backgroundSprite;

  Rect _knobRect;
  Sprite _knobSprite;

  bool _dragging = false;
  Offset _dragPosition;

  double _tileSize;
  Size _screenSize;

  int currentGesturePointer = 0;

  Paint _paintBackground;
  Paint _paintKnob;

  final double sizeDirectional;
  final double marginBottomDirectional;
  final double marginLeftDirectional;
  final String pathSpriteBackgroundDirectional;
  final String pathSpriteKnobDirectional;
  final List<JoystickAction> actions;
  final bool isFixedDirectional;

  Joystick({
    this.pathSpriteBackgroundDirectional,
    this.pathSpriteKnobDirectional,
    Color directionalColor,
    this.actions,
    this.sizeDirectional = 80,
    this.marginBottomDirectional = 100,
    this.marginLeftDirectional = 100,
    this.isFixedDirectional = true,
  }) {
    Color color = directionalColor ?? Colors.blueGrey;
    if (pathSpriteBackgroundDirectional != null) {
      _backgroundSprite = Sprite(pathSpriteBackgroundDirectional);
    } else {
      _paintBackground = Paint()
        ..color = color.withOpacity(0.5)
        ..style = PaintingStyle.fill;
    }
    if (pathSpriteKnobDirectional != null) {
      _knobSprite = Sprite(pathSpriteKnobDirectional);
    } else {
      _paintKnob = Paint()
        ..color = color.withOpacity(0.8)
        ..style = PaintingStyle.fill;
    }

    _tileSize = sizeDirectional / 2;
  }

  void initialize() async {
    _screenSize = gameRef.size;
    Offset osBackground = Offset(
        marginLeftDirectional, _screenSize.height - marginBottomDirectional);
    _backgroundRect =
        Rect.fromCircle(center: osBackground, radius: sizeDirectional / 2);

    Offset osKnob =
        Offset(_backgroundRect.center.dx, _backgroundRect.center.dy);
    _knobRect = Rect.fromCircle(center: osKnob, radius: sizeDirectional / 4);

    _dragPosition = _knobRect.center;

    if (actions != null)
      actions.forEach(
          (action) => action.initialize(_screenSize, joystickListener));
  }

  void addAction(JoystickAction action) {
    if (actions != null) {
      action.initialize(_screenSize, joystickListener);
      actions.add(action);
    }
  }

  void removeAction(int actionId) {
    if (actions != null)
      actions.removeWhere((action) => action.actionId == actionId);
  }

  void render(Canvas canvas) {
    if (_backgroundRect != null) {
      if (_backgroundSprite != null) {
        _backgroundSprite.renderRect(canvas, _backgroundRect);
      } else {
        double radiusBackground = _backgroundRect.width / 2;
        canvas.drawCircle(
          Offset(_backgroundRect.left + radiusBackground,
              _backgroundRect.top + radiusBackground),
          radiusBackground,
          _paintBackground,
        );
      }
    }

    if (_knobRect != null) {
      if (_knobSprite != null) {
        _knobSprite.renderRect(canvas, _knobRect);
      } else {
        double radiusKnob = _knobRect.width / 2;
        canvas.drawCircle(
          Offset(_knobRect.left + radiusKnob, _knobRect.top + radiusKnob),
          radiusKnob,
          _paintKnob,
        );
      }
    }

    if (actions != null) actions.forEach((action) => action.render(canvas));
  }

  void update(double t) {
    if (gameRef.size != null && _screenSize != gameRef.size) {
      initialize();
    }

    if (actions != null) actions.forEach((action) => action.update(t));

    if (_backgroundRect == null) {
      return;
    }

    if (_dragging) {
      double _radAngle = atan2(_dragPosition.dy - _backgroundRect.center.dy,
          _dragPosition.dx - _backgroundRect.center.dx);

      double degrees = _radAngle * 180 / pi;

      // Distance between the center of joystick background & drag position
      Point p = Point(_backgroundRect.center.dx, _backgroundRect.center.dy);
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

      Offset diff = Offset(_backgroundRect.center.dx + nextPoint.dx,
              _backgroundRect.center.dy + nextPoint.dy) -
          _knobRect.center;
      _knobRect = _knobRect.shift(diff);

      double _intensity = dist / (_tileSize * _backgroundAspectRatio / 3);

      if (degrees > -22.5 && degrees <= 22.5) {
        joystickListener.joystickChangeDirectional(JoystickDirectionalEvent(
          directional: JoystickMoveDirectional.MOVE_RIGHT,
          intensity: _intensity,
          radAngle: _radAngle,
        ));
      }

      if (degrees > 22.5 && degrees <= 67.5) {
        joystickListener.joystickChangeDirectional(JoystickDirectionalEvent(
          directional: JoystickMoveDirectional.MOVE_DOWN_RIGHT,
          intensity: _intensity,
          radAngle: _radAngle,
        ));
      }

      if (degrees > 67.5 && degrees <= 112.5) {
        joystickListener.joystickChangeDirectional(JoystickDirectionalEvent(
          directional: JoystickMoveDirectional.MOVE_DOWN,
          intensity: _intensity,
          radAngle: _radAngle,
        ));
      }

      if (degrees > 112.5 && degrees <= 157.5) {
        joystickListener.joystickChangeDirectional(JoystickDirectionalEvent(
          directional: JoystickMoveDirectional.MOVE_DOWN_LEFT,
          intensity: _intensity,
          radAngle: _radAngle,
        ));
      }

      if ((degrees > 157.5 && degrees <= 180) ||
          (degrees >= -180 && degrees <= -157.5)) {
        joystickListener.joystickChangeDirectional(JoystickDirectionalEvent(
          directional: JoystickMoveDirectional.MOVE_LEFT,
          intensity: _intensity,
          radAngle: _radAngle,
        ));
      }

      if (degrees > -157.5 && degrees <= -112.5) {
        joystickListener.joystickChangeDirectional(JoystickDirectionalEvent(
          directional: JoystickMoveDirectional.MOVE_UP_LEFT,
          intensity: _intensity,
          radAngle: _radAngle,
        ));
      }

      if (degrees > -112.5 && degrees <= -67.5) {
        joystickListener.joystickChangeDirectional(JoystickDirectionalEvent(
          directional: JoystickMoveDirectional.MOVE_UP,
          intensity: _intensity,
          radAngle: _radAngle,
        ));
      }

      if (degrees > -67.5 && degrees <= -22.5) {
        joystickListener.joystickChangeDirectional(JoystickDirectionalEvent(
          directional: JoystickMoveDirectional.MOVE_UP_RIGHT,
          intensity: _intensity,
          radAngle: _radAngle,
        ));
      }
    } else {
      if (_knobRect != null) {
        Offset diff = _dragPosition - _knobRect.center;
        _knobRect = _knobRect.shift(diff);
      }
    }
  }

  void onPointerDown(PointerDownEvent event) {
    _updateDirectionalRect(event.localPosition);

    if (actions != null)
      actions.forEach(
          (action) => action.actionDown(event.pointer, event.localPosition));
//    if (actions == null || actions.isEmpty) return;
//    actions
//        .where((action) =>
//            action.rect != null && action.rect.contains(event.localPosition))
//        .forEach((action) {
//      action.pressed();
//      joystickListener.joystickAction(action.actionId);
//    });

    if (_backgroundRect == null) return;
    Rect directional = Rect.fromLTWH(
      _backgroundRect.left - 50,
      _backgroundRect.top - 50,
      _backgroundRect.width + 100,
      _backgroundRect.height + 100,
    );
    if (!_dragging && directional.contains(event.localPosition)) {
      _dragging = true;
      _dragPosition = event.localPosition;
      currentGesturePointer = event.pointer;
    }
  }

  void onPointerMove(PointerMoveEvent event) {
    if (actions != null)
      actions.forEach(
          (action) => action.actionMove(event.pointer, event.localPosition));
    if (event.pointer == currentGesturePointer) {
      if (_dragging) {
        _dragPosition = event.localPosition;
      }
    }
  }

  void onPointerUp(PointerUpEvent event) {
    if (actions != null)
      actions.forEach((action) => action.actionUp(event.pointer));

    if (event.pointer == currentGesturePointer) {
      _dragging = false;
      _dragPosition = _backgroundRect.center;
      joystickListener.joystickChangeDirectional(JoystickDirectionalEvent(
        directional: JoystickMoveDirectional.IDLE,
        intensity: 0.0,
        radAngle: 0.0,
      ));
    }
  }

  void onPointerCancel(PointerCancelEvent event) {
    if (actions != null)
      actions.forEach((action) => action.actionUp(event.pointer));
    if (event.pointer == currentGesturePointer) {
      _dragging = false;
      _dragPosition = _backgroundRect.center;
      joystickListener.joystickChangeDirectional(JoystickDirectionalEvent(
        directional: JoystickMoveDirectional.IDLE,
        intensity: 0.0,
        radAngle: 0.0,
      ));
    }
  }

  void _updateDirectionalRect(Offset position) {
    if (gameRef != null &&
        (position.dx > gameRef.size.width / 3 ||
            position.dy < gameRef.size.height / 3 ||
            isFixedDirectional)) return;

    _backgroundRect =
        Rect.fromCircle(center: position, radius: sizeDirectional / 2);

    Offset osKnob =
        Offset(_backgroundRect.center.dx, _backgroundRect.center.dy);
    _knobRect = Rect.fromCircle(center: osKnob, radius: sizeDirectional / 4);
  }
}
