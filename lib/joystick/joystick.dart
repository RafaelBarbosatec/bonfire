import 'package:bonfire/joystick/joystick_action.dart';
import 'package:bonfire/joystick/joystick_controller.dart';
import 'package:bonfire/joystick/joystick_directional.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Joystick extends JoystickController {
  final List<JoystickAction> actions;
  final JoystickDirectional directional;

  Joystick({
    this.actions,
    this.directional,
  });

  void initialize(Size size) async {
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

  void removeAction(int actionId) {
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
  void resize(Size size) {
    initialize(size);
    super.resize(size);
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
