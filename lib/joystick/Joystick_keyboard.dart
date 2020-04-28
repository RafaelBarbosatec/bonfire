import 'package:bonfire/joystick/joystick_controller.dart';
import 'package:flutter/services.dart';

// Only Flutter Web
class JoystickKeyBoard extends JoystickController {
  @override
  void onKeyboard(RawKeyEvent event) {
    if (event.runtimeType == RawKeyDownEvent) {
      bool isDirectional = false;
      if (event.logicalKey.keyId == 40) {
        isDirectional = true;
        joystickListener.joystickChangeDirectional(
          JoystickMoveDirectional.MOVE_DOWN,
          1,
          0,
        );
      }
      if (event.logicalKey.keyId == 38) {
        isDirectional = true;
        joystickListener.joystickChangeDirectional(
          JoystickMoveDirectional.MOVE_UP,
          1,
          0,
        );
      }
      if (event.logicalKey.keyId == 37) {
        isDirectional = true;
        joystickListener.joystickChangeDirectional(
          JoystickMoveDirectional.MOVE_LEFT,
          1,
          0,
        );
      }
      if (event.logicalKey.keyId == 39) {
        isDirectional = true;
        joystickListener.joystickChangeDirectional(
          JoystickMoveDirectional.MOVE_RIGHT,
          1,
          0,
        );
      }

      if (!isDirectional) {
        joystickListener.joystickAction(event.logicalKey.keyId);
      }
    } else {
      joystickListener.joystickChangeDirectional(
        JoystickMoveDirectional.IDLE,
        1,
        0,
      );
    }
  }
}
