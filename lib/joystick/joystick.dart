import 'package:bonfire/joystick/joystick_action.dart';
import 'package:bonfire/joystick/joystick_controller.dart';
import 'package:bonfire/joystick/joystick_directional.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Joystick extends JoystickController {
  final List<JoystickAction> actions;
  final JoystickDirectional directional;
  Size _screenSize;

  Joystick({
    this.actions,
    this.directional,
  });

  void initialize() async {
    _screenSize = gameRef.size;
    if (directional != null)
      directional.initialize(_screenSize, joystickListener);
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
    if (directional != null) directional.render(canvas);
    if (actions != null) actions.forEach((action) => action.render(canvas));
  }

  void update(double t) {
    if (gameRef.size != null && _screenSize != gameRef.size) {
      initialize();
    }

    if (directional != null) directional.update(t);
    if (actions != null) actions.forEach((action) => action.update(t));
  }

  void onPointerDown(PointerDownEvent event) {
    if (directional != null)
      directional.directionalDown(event.pointer, event.localPosition);
    if (actions != null)
      actions.forEach(
          (action) => action.actionDown(event.pointer, event.localPosition));
  }

  void onPointerMove(PointerMoveEvent event) {
    if (actions != null)
      actions.forEach(
          (action) => action.actionMove(event.pointer, event.localPosition));
    if (directional != null)
      directional.directionalMove(event.pointer, event.localPosition);
  }

  void onPointerUp(PointerUpEvent event) {
    if (actions != null)
      actions.forEach((action) => action.actionUp(event.pointer));

    if (directional != null) directional.directionalUp(event.pointer);
  }

  void onPointerCancel(PointerCancelEvent event) {
    if (actions != null)
      actions.forEach((action) => action.actionUp(event.pointer));
    if (directional != null) directional.directionalUp(event.pointer);
  }
}
