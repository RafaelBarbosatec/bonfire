import 'package:bonfire/bonfire.dart';
import 'package:bonfire/joystick/joystick_action.dart';
import 'package:bonfire/joystick/joystick_controller.dart';
import 'package:bonfire/joystick/joystick_directional.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class Joystick extends JoystickController {
  final List<JoystickAction> actions;
  final JoystickDirectional directional;
  final bool keyboardEnable;
  bool _isDirectionalDownKeyboard = false;
  LogicalKeyboardKey _currentDirectionalKey;

  Joystick({
    this.actions,
    this.directional,
    this.keyboardEnable = false,
  });

  void initialize(Vector2 size) async {
    if (directional != null) directional.initialize(size, this);
    if (actions != null)
      actions.forEach((action) => action.initialize(size, this));
  }

  void addAction(JoystickAction action) {
    if (actions != null && gameRef?.size != null) {
      action.initialize(gameRef.size, this);
      actions.add(action);
    }
  }

  void removeAction(dynamic actionId) {
    if (actions != null)
      actions.removeWhere((action) => action.actionId == actionId);
  }

  void render(Canvas canvas) {
    if (directional != null) directional.render(canvas);
    if (actions != null) actions.forEach((action) => action.render(canvas));
  }

  void update(double t) {
    if (directional != null) directional.update(t);
    if (actions != null) actions.forEach((action) => action.update(t));
  }

  @override
  void onGameResize(Vector2 gameSize) {
    initialize(gameSize);
    super.onGameResize(gameSize);
  }

  @override
  void onDragStart(int pointerId, Vector2 startPosition) {
    directional?.directionalDown(pointerId, startPosition.toOffset());

    actions?.where((element) => element.enableDirection)?.forEach((action) {
      action.onDragStart(pointerId, startPosition.toOffset());
    });
    super.onDragStart(pointerId, startPosition);
  }

  @override
  void onDragUpdate(int pointerId, DragUpdateDetails details) {
    actions?.where((element) => element.enableDirection)?.forEach(
        (action) => action.onDragUpdate(pointerId, details.localPosition));

    directional?.directionalMove(pointerId, details.localPosition);
    super.onDragUpdate(pointerId, details);
  }

  @override
  void onDragEnd(int pointerId, DragEndDetails details) {
    actions
        ?.where((element) => element.enableDirection)
        ?.forEach((action) => action.onDragEnd(pointerId));

    if (directional != null) directional.directionalUp(pointerId);
    super.onDragEnd(pointerId, details);
  }

  @override
  void onDragCancel(int pointerId) {
    if (actions != null)
      actions
          ?.where((element) => element.enableDirection)
          ?.forEach((action) => action.onDragEnd(pointerId));
    if (directional != null) directional.directionalUp(pointerId);
    super.onDragCancel(pointerId);
  }

  @override
  void onTapDown(int pointerId, TapDownDetails details) {
    actions?.forEach((action) {
      action.onTapDown(pointerId, details.localPosition);
    });
    super.onTapDown(pointerId, details);
  }

  @override
  void onTapUp(int pointerId, TapUpDetails details) {
    actions?.forEach((action) => action.onTapUp(pointerId));
    super.onTapUp(pointerId, details);
  }

  @override
  void onKeyboard(RawKeyEvent event) {
    if (!keyboardEnable) return;
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        _isDirectionalDownKeyboard = true;
        _currentDirectionalKey = event.logicalKey;
        joystickChangeDirectional(JoystickDirectionalEvent(
          directional: JoystickMoveDirectional.MOVE_DOWN,
          intensity: 1.0,
          radAngle: 0.0,
        ));
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        _isDirectionalDownKeyboard = true;
        _currentDirectionalKey = event.logicalKey;
        joystickChangeDirectional(JoystickDirectionalEvent(
          directional: JoystickMoveDirectional.MOVE_UP,
          intensity: 1.0,
          radAngle: 0.0,
        ));
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        _isDirectionalDownKeyboard = true;
        _currentDirectionalKey = event.logicalKey;
        joystickChangeDirectional(JoystickDirectionalEvent(
          directional: JoystickMoveDirectional.MOVE_LEFT,
          intensity: 1.0,
          radAngle: 0.0,
        ));
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        _isDirectionalDownKeyboard = true;
        _currentDirectionalKey = event.logicalKey;
        joystickChangeDirectional(JoystickDirectionalEvent(
          directional: JoystickMoveDirectional.MOVE_RIGHT,
          intensity: 1.0,
          radAngle: 0.0,
        ));
      }

      if (!_isDirectionalDownKeyboard) {
        joystickAction(JoystickActionEvent(
          id: event.logicalKey.keyId,
        ));
      }
    } else if (event is RawKeyUpEvent &&
        _isDirectionalDownKeyboard &&
        _currentDirectionalKey == event.logicalKey) {
      _isDirectionalDownKeyboard = false;
      joystickChangeDirectional(JoystickDirectionalEvent(
        directional: JoystickMoveDirectional.IDLE,
        intensity: 0.0,
        radAngle: 0.0,
      ));
    }
  }
}
