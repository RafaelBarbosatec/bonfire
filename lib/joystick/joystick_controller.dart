import 'dart:ui';

import 'package:bonfire/rpg_game.dart';
import 'package:bonfire/util/gesture/pointer_detector.dart';
import 'package:flame/components/component.dart';
import 'package:flame/components/mixins/has_game_ref.dart';
import 'package:flame/gestures.dart';
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

abstract class JoystickListener {
  void joystickChangeDirectional(
      JoystickMoveDirectional directional, double intensity, double radAngle);
  void joystickAction(int action);
}

abstract class JoystickController extends Component
    with HasGameRef<RPGGame>, TapDetector, PointerDetector {
  JoystickListener joystickListener;

  void onKeyboard(RawKeyEvent event) {}

  @override
  void render(Canvas c) {}

  @override
  void update(double t) {}

  @override
  int priority() {
    return 20;
  }
}
