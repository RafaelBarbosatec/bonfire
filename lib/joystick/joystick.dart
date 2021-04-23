import 'package:bonfire/bonfire.dart';
import 'package:bonfire/joystick/joystick_action.dart';
import 'package:bonfire/joystick/joystick_controller.dart';
import 'package:bonfire/joystick/joystick_directional.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class Joystick extends JoystickController {
  final List<JoystickAction>? actions;
  final JoystickDirectional? directional;
  final bool keyboardEnable;
  List<LogicalKeyboardKey> _currentKeyboardKeys = [];

  Joystick({
    this.actions,
    this.directional,
    this.keyboardEnable = false,
  });

  void initialize(Vector2 size) async {
    directional?.initialize(size, this);
    actions?.forEach((action) => action.initialize(size, this));
  }

  Future addAction(JoystickAction action) async {
    if (actions != null) {
      action.initialize(gameRef.size, this);
      await action.onLoad();
      actions?.add(action);
    }
  }

  void removeAction(dynamic actionId) {
    actions?.removeWhere((action) => action.actionId == actionId);
  }

  void render(Canvas canvas) {
    directional?.render(canvas);
    actions?.forEach((action) => action.render(canvas));
  }

  void update(double t) {
    directional?.update(t);
    actions?.forEach((action) => action.update(t));
  }

  @override
  void handlerPointerCancel(PointerCancelEvent event) {
    actions?.forEach((action) => action.actionUp(event.pointer));
    directional?.directionalUp(event.pointer);
  }

  @override
  void handlerPointerDown(PointerDownEvent event) {
    directional?.directionalDown(event.pointer, event.localPosition);
    actions?.forEach((action) {
      action.actionDown(event.pointer, event.localPosition);
    });
  }

  @override
  void handlerPointerMove(PointerMoveEvent event) {
    actions?.forEach((action) {
      action.actionMove(event.pointer, event.localPosition);
    });
    directional?.directionalMove(event.pointer, event.localPosition);
  }

  @override
  void handlerPointerUp(PointerUpEvent event) {
    actions?.forEach((action) => action.actionUp(event.pointer));
    directional?.directionalUp(event.pointer);
  }

  @override
  void onKeyboard(RawKeyEvent event) {
    if (!keyboardEnable) return;

    if (_isDirectional(event)) {
      if (event is RawKeyDownEvent && _currentKeyboardKeys.length < 2) {
        if (!_currentKeyboardKeys.contains(event.logicalKey)) {
          _currentKeyboardKeys.add(event.logicalKey);
        }
      }

      if (event is RawKeyUpEvent && _currentKeyboardKeys.length > 0) {
        _currentKeyboardKeys.remove(event.logicalKey);
      }

      if (_currentKeyboardKeys.isEmpty) {
        joystickChangeDirectional(JoystickDirectionalEvent(
          directional: JoystickMoveDirectional.IDLE,
          intensity: 0.0,
          radAngle: 0.0,
        ));
      } else {
        if (_currentKeyboardKeys.length == 1) {
          _sendOneDirection(_currentKeyboardKeys.first);
        } else {
          _sendTwoDirection(
              _currentKeyboardKeys.first, _currentKeyboardKeys[1]);
        }
      }
    } else {
      if (event is RawKeyDownEvent) {
        joystickAction(JoystickActionEvent(
          id: event.logicalKey.keyId,
          event: ActionEvent.DOWN,
        ));
      } else if (event is RawKeyUpEvent) {
        joystickAction(JoystickActionEvent(
          id: event.logicalKey.keyId,
          event: ActionEvent.UP,
        ));
      }
    }
  }

  @override
  void onGameResize(Vector2 gameSize) {
    initialize(gameSize);
    super.onGameResize(gameSize);
  }

  @override
  Future<void> onLoad() async {
    await directional?.onLoad();
    if (actions != null) {
      await Future.forEach<JoystickAction>(actions!, (element) {
        return element.onLoad();
      });
    }
  }

  bool _isDirectional(RawKeyEvent event) {
    return event.logicalKey == LogicalKeyboardKey.arrowRight ||
        event.logicalKey == LogicalKeyboardKey.arrowUp ||
        event.logicalKey == LogicalKeyboardKey.arrowLeft ||
        event.logicalKey == LogicalKeyboardKey.arrowDown;
  }

  void _sendOneDirection(LogicalKeyboardKey key) {
    if (key == LogicalKeyboardKey.arrowRight) {
      joystickChangeDirectional(JoystickDirectionalEvent(
        directional: JoystickMoveDirectional.MOVE_RIGHT,
        intensity: 1.0,
        radAngle: 0.0,
      ));
    }

    if (key == LogicalKeyboardKey.arrowUp) {
      joystickChangeDirectional(JoystickDirectionalEvent(
        directional: JoystickMoveDirectional.MOVE_UP,
        intensity: 1.0,
        radAngle: 0.0,
      ));
    }

    if (key == LogicalKeyboardKey.arrowLeft) {
      joystickChangeDirectional(JoystickDirectionalEvent(
        directional: JoystickMoveDirectional.MOVE_LEFT,
        intensity: 1.0,
        radAngle: 0.0,
      ));
    }

    if (key == LogicalKeyboardKey.arrowDown) {
      joystickChangeDirectional(JoystickDirectionalEvent(
        directional: JoystickMoveDirectional.MOVE_DOWN,
        intensity: 1.0,
        radAngle: 0.0,
      ));
    }
  }

  void _sendTwoDirection(LogicalKeyboardKey key1, LogicalKeyboardKey key2) {
    if (key1 == LogicalKeyboardKey.arrowRight &&
            key2 == LogicalKeyboardKey.arrowDown ||
        key2 == LogicalKeyboardKey.arrowRight &&
            key1 == LogicalKeyboardKey.arrowDown) {
      joystickChangeDirectional(JoystickDirectionalEvent(
        directional: JoystickMoveDirectional.MOVE_DOWN_RIGHT,
        intensity: 1.0,
        radAngle: 0.0,
      ));
    }

    if (key1 == LogicalKeyboardKey.arrowLeft &&
            key2 == LogicalKeyboardKey.arrowDown ||
        key2 == LogicalKeyboardKey.arrowLeft &&
            key1 == LogicalKeyboardKey.arrowDown) {
      joystickChangeDirectional(JoystickDirectionalEvent(
        directional: JoystickMoveDirectional.MOVE_DOWN_LEFT,
        intensity: 1.0,
        radAngle: 0.0,
      ));
    }

    if (key1 == LogicalKeyboardKey.arrowLeft &&
            key2 == LogicalKeyboardKey.arrowUp ||
        key2 == LogicalKeyboardKey.arrowLeft &&
            key1 == LogicalKeyboardKey.arrowUp) {
      joystickChangeDirectional(JoystickDirectionalEvent(
        directional: JoystickMoveDirectional.MOVE_UP_LEFT,
        intensity: 1.0,
        radAngle: 0.0,
      ));
    }

    if (key1 == LogicalKeyboardKey.arrowRight &&
            key2 == LogicalKeyboardKey.arrowUp ||
        key2 == LogicalKeyboardKey.arrowRight &&
            key1 == LogicalKeyboardKey.arrowUp) {
      joystickChangeDirectional(JoystickDirectionalEvent(
        directional: JoystickMoveDirectional.MOVE_UP_RIGHT,
        intensity: 1.0,
        radAngle: 0.0,
      ));
    }
  }
}
