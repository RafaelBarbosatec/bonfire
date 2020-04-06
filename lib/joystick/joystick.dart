import 'dart:math';
import 'dart:ui';

import 'package:bonfire/joystick/joystick_action.dart';
import 'package:bonfire/joystick/joystick_controller.dart';
import 'package:bonfire/util/gesture/pointer_detector.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/widgets.dart';

class Joystick extends JoystickController with PointerDetector {
  double _backgroundAspectRatio = 2.2;
  Rect _backgroundRect;
  Sprite _backgroundSprite;

  Rect _knobRect;
  Sprite _knobSprite;

  bool _dragging = false;
  Offset _dragPosition;

  double _sensitivity = 6;

  double _tileSize;
  Size _screenSize;

  int currentGesturePointer = 0;

  final double sizeDirectional;
  final double marginBottomDirectional;
  final double marginLeftDirectional;
  final String pathSpriteBackgroundDirectional;
  final String pathSpriteKnobDirectional;
  final List<JoystickAction> actions;

  Joystick({
    @required this.pathSpriteBackgroundDirectional,
    @required this.pathSpriteKnobDirectional,
    this.actions,
    this.sizeDirectional = 80,
    this.marginBottomDirectional = 100,
    this.marginLeftDirectional = 100,
  }) {
    _backgroundSprite = Sprite(pathSpriteBackgroundDirectional);
    _knobSprite = Sprite(pathSpriteKnobDirectional);
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

    if (actions != null) {
      actions.forEach((action) => _setRectInAction(action));
    }
  }

  void _setRectInAction(JoystickAction action) {
    double radius = action.size / 2;
    double dx = 0, dy = 0;
    switch (action.align) {
      case JoystickActionAlign.TOP_LEFT:
        dx = action.margin.left + radius;
        dy = action.margin.top + radius;
        break;
      case JoystickActionAlign.BOTTOM_LEFT:
        dx = action.margin.left + radius;
        dy = _screenSize.height - (action.margin.bottom + radius);
        break;
      case JoystickActionAlign.TOP_RIGHT:
        dx = _screenSize.width - (action.margin.right + radius);
        dy = action.margin.top + radius;
        break;
      case JoystickActionAlign.BOTTOM_RIGHT:
        dx = _screenSize.width - (action.margin.right + radius);
        dy = _screenSize.height - (action.margin.bottom + radius);
        break;
    }
    action.rect = Rect.fromCircle(
      center: Offset(dx, dy),
      radius: radius,
    );
  }

  void addAction(JoystickAction action) {
    _setRectInAction(action);
    actions.add(action);
  }

  void removeAction(int actionId) {
    actions.removeWhere((action) => action.actionId == actionId);
  }

  void render(Canvas canvas) {
    if (_backgroundSprite != null)
      _backgroundSprite.renderRect(canvas, _backgroundRect);
    if (_knobSprite != null) _knobSprite.renderRect(canvas, _knobRect);

    if (actions != null) actions.forEach((action) => action.render(canvas));
  }

  void update(double t) {
    if (gameRef.size != null && _screenSize != gameRef.size) {
      initialize();
    }

    if (_backgroundRect == null) {
      return;
    }

    if (_dragging) {
      double _radAngle = atan2(_dragPosition.dy - _backgroundRect.center.dy,
          _dragPosition.dx - _backgroundRect.center.dx);

      // Distance between the center of joystick background & drag position
      Point p = Point(_backgroundRect.center.dx, _backgroundRect.center.dy);
      double dist = p.distanceTo(Point(_dragPosition.dx, _dragPosition.dy));

      bool mRight = false;
      bool mLeft = false;
      bool mTop = false;
      bool mBottom = false;

      var diffY = _dragPosition.dy - _backgroundRect.center.dy;
      var diffX = _dragPosition.dx - _backgroundRect.center.dx;
      if (_dragPosition.dx > _backgroundRect.center.dx &&
          diffX > _backgroundRect.width / _sensitivity) {
        mRight = true;
      }
      if (_dragPosition.dx < _backgroundRect.center.dx &&
          diffX < (-1 * _backgroundRect.width / _sensitivity)) {
        mLeft = true;
      }
      if (_dragPosition.dy > _backgroundRect.center.dy &&
          diffY > _backgroundRect.height / _sensitivity) {
        mBottom = true;
      }
      if (_dragPosition.dy < _backgroundRect.center.dy &&
          diffY < (-1 * _backgroundRect.height / _sensitivity)) {
        mTop = true;
      }

      if (mRight && mTop) {
        mRight = false;
        mTop = false;
        joystickListener
            .joystickChangeDirectional(JoystickMoveDirectional.MOVE_TOP_RIGHT);
      }

      if (mRight && mBottom) {
        mRight = false;
        mBottom = false;
        joystickListener.joystickChangeDirectional(
            JoystickMoveDirectional.MOVE_BOTTOM_RIGHT);
      }

      if (mLeft && mTop) {
        mLeft = false;
        mTop = false;
        joystickListener
            .joystickChangeDirectional(JoystickMoveDirectional.MOVE_TOP_LEFT);
      }

      if (mLeft && mBottom) {
        mLeft = false;
        mBottom = false;
        joystickListener.joystickChangeDirectional(
            JoystickMoveDirectional.MOVE_BOTTOM_LEFT);
      }

      if (mRight) {
        joystickListener
            .joystickChangeDirectional(JoystickMoveDirectional.MOVE_RIGHT);
      }

      if (mLeft) {
        joystickListener
            .joystickChangeDirectional(JoystickMoveDirectional.MOVE_LEFT);
      }

      if (mBottom) {
        joystickListener
            .joystickChangeDirectional(JoystickMoveDirectional.MOVE_BOTTOM);
      }

      if (mTop) {
        joystickListener
            .joystickChangeDirectional(JoystickMoveDirectional.MOVE_TOP);
      }

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
    } else {
      if (_knobRect != null) {
        Offset diff = _dragPosition - _knobRect.center;
        _knobRect = _knobRect.shift(diff);
      }
    }
  }

  @override
  void onTapDown(TapDownDetails details) {
    actions
        .where((action) => action.rect.contains(details.globalPosition))
        .forEach((action) {
      action.pressed();
      joystickListener.joystickAction(action.actionId);
    });
    super.onTapDown(details);
  }

  @override
  void onTapUp(TapUpDetails details) {
    actions.forEach((action) {
      action.unPressed();
    });
    super.onTapUp(details);
  }

  @override
  void onTapCancel() {
    actions.forEach((action) {
      action.unPressed();
    });
    super.onTapCancel();
  }

  void onPointerDown(PointerDownEvent event) {
    if (!_dragging && _backgroundRect.contains(event.position)) {
      _dragging = true;
      currentGesturePointer = event.pointer;
    }
  }

  void onPointerMove(PointerMoveEvent event) {
    if (event.pointer == currentGesturePointer) {
      if (_dragging) {
        _dragPosition = event.position;
      }
    }
  }

  void onPointerUp(PointerUpEvent event) {
    if (event.pointer == currentGesturePointer) {
      _dragging = false;
      _dragPosition = _backgroundRect.center;
      joystickListener.joystickChangeDirectional(JoystickMoveDirectional.IDLE);
    }
  }

  void onPointerCancel(PointerCancelEvent event) {
    if (event.pointer == currentGesturePointer) {
      _dragging = false;
      _dragPosition = _backgroundRect.center;
      joystickListener.joystickChangeDirectional(JoystickMoveDirectional.IDLE);
    }
  }
}
