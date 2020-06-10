import 'dart:ui';

import 'package:bonfire/rpg_game.dart';
import 'package:bonfire/util/gestures.dart';
import 'package:flame/components/component.dart';
import 'package:flame/components/mixins/has_game_ref.dart';
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
  final int id;
  final double intensity;
  final double radAngle;
  final ActionEvent event;

  JoystickActionEvent(
      {this.id, this.intensity = 0.0, this.radAngle = 0.0, this.event});
}

abstract class JoystickListener {
  void joystickChangeDirectional(JoystickDirectionalEvent event);
  void joystickAction(JoystickActionEvent event);
}

abstract class JoystickController extends Component
    with HasGameRef<RPGGame>, PointerDetector {
  JoystickListener joystickListener;

  void onKeyboard(RawKeyEvent event) {}

  @override
  void render(Canvas c) {}

  @override
  void update(double t) {}

  @override
  int priority() => 100;

  @override
  bool isHud() => true;
}
