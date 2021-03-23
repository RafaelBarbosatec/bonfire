import 'dart:ui';

import 'package:bonfire/base/custom_base_game.dart';
import 'package:bonfire/util/mixins/pointer_detector_mixin.dart';
import 'package:bonfire/util/priority_layer.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';

enum JoystickMoveDirectional {
  MOVE_UP,
  MOVE_UP_LEFT,
  MOVE_UP_RIGHT,
  MOVE_RIGHT,
  MOVE_DOWN,
  MOVE_DOWN_RIGHT,
  MOVE_DOWN_LEFT,
  MOVE_LEFT,
  IDLE
}

class JoystickDirectionalEvent {
  final JoystickMoveDirectional directional;
  final double intensity;
  final double radAngle;

  JoystickDirectionalEvent({
    this.directional,
    this.intensity = 0.0,
    this.radAngle = 0.0,
  });
}

enum ActionEvent { DOWN, UP, MOVE }

class JoystickActionEvent {
  final dynamic id;
  final double intensity;
  final double radAngle;
  final ActionEvent event;

  JoystickActionEvent({
    this.id,
    this.intensity = 0.0,
    this.radAngle = 0.0,
    this.event,
  });
}

abstract class JoystickListener {
  void joystickChangeDirectional(JoystickDirectionalEvent event);
  void joystickAction(JoystickActionEvent event);
  void moveTo(Vector2 position);
}

abstract class JoystickController extends Component
    with HasGameRef<CustomBaseGame>, PointerDetector {
  List<JoystickListener> _observers = [];
  bool keyboardEnable = false;

  void onKeyboard(RawKeyEvent event) {}

  void joystickChangeDirectional(JoystickDirectionalEvent event) {
    _observers.forEach((o) => o.joystickChangeDirectional(event));
  }

  void joystickAction(JoystickActionEvent event) {
    _observers.forEach((o) => o.joystickAction(event));
  }

  void moveTo(Vector2 event) {
    _observers.forEach((o) => o.moveTo(event));
  }

  void addObserver(JoystickListener listener) {
    _observers.add(listener);
  }

  @override
  void render(Canvas c) {}

  @override
  void update(double t) {}

  @override
  int get priority => PriorityLayer.JOYSTICK;

  @override
  bool get isHud => true;
}
