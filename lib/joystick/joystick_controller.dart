import 'dart:ui';

import 'package:bonfire/rpg_game.dart';
import 'package:flame/components/component.dart';
import 'package:flame/components/mixins/has_game_ref.dart';
import 'package:flutter/gestures.dart';

enum JoystickMoveDirectional {
  MOVE_TOP,
  MOVE_TOP_LEFT,
  MOVE_TOP_RIGHT,
  MOVE_RIGHT,
  MOVE_BOTTOM,
  MOVE_BOTTOM_RIGHT,
  MOVE_BOTTOM_LEFT,
  MOVE_LEFT,
  IDLE
}

abstract class JoystickListener {
  void joystickChangeDirectional(JoystickMoveDirectional directional);
  void joystickAction(int action);
}

abstract class JoystickController extends Component with HasGameRef<RPGGame> {
  JoystickListener joystickListener;
  @override
  void render(Canvas c) {}

  @override
  void update(double t) {}

  @override
  int priority() {
    return 20;
  }

  void onPanStart(DragStartDetails details) {}
  void onTapDown(TapDownDetails details) {}
  void onTapUp(TapUpDetails details) {}
  void onPanUpdate(DragUpdateDetails details) {}
  void onPanEnd(DragEndDetails details) {}

  void onTapDownAction(TapDownDetails details) {}
  void onTapUpAction(TapUpDetails details) {}
  void onTapCancelAction() {}
}
