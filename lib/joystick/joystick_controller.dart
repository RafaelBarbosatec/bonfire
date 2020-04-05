import 'dart:ui';

import 'package:bonfire/rpg_game.dart';
import 'package:bonfire/util/gesture/ListenerPointer.dart';
import 'package:flame/components/component.dart';
import 'package:flame/components/mixins/has_game_ref.dart';
import 'package:flame/gestures.dart';

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

abstract class JoystickController extends Component
    with HasGameRef<RPGGame>, TapDetector, PointerDetector {
  JoystickListener joystickListener;
  @override
  void render(Canvas c) {}

  @override
  void update(double t) {}

  @override
  int priority() {
    return 20;
  }
}
