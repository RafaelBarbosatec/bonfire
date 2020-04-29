import 'package:bonfire/joystick/joystick_controller.dart';
import 'package:flutter/services.dart';

// Only Flutter Web
class JoystickKeyBoard extends JoystickController {
  bool isDirectionalDown = false;
  @override
  void onKeyboard(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        isDirectionalDown = true;
        joystickListener.joystickChangeDirectional(
          JoystickMoveDirectional.MOVE_DOWN,
          1,
          0,
        );
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        isDirectionalDown = true;
        joystickListener.joystickChangeDirectional(
          JoystickMoveDirectional.MOVE_UP,
          1,
          0,
        );
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        isDirectionalDown = true;
        joystickListener.joystickChangeDirectional(
          JoystickMoveDirectional.MOVE_LEFT,
          1,
          0,
        );
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        isDirectionalDown = true;
        joystickListener.joystickChangeDirectional(
          JoystickMoveDirectional.MOVE_RIGHT,
          1,
          0,
        );
      }

      if (!isDirectionalDown) {
        joystickListener.joystickAction(event.logicalKey.keyId);
      }
    } else if (event is RawKeyUpEvent && isDirectionalDown) {
      isDirectionalDown = false;
      joystickListener.joystickChangeDirectional(
        JoystickMoveDirectional.IDLE,
        1,
        0,
      );
    }
  }
}
