import 'package:bonfire/joystick/joystick_controller.dart';
import 'package:flutter/services.dart';

// Only Flutter Web
class JoystickKeyBoard extends JoystickController {
  bool isDirectionalDown = false;
  LogicalKeyboardKey currentDirectionalKey;
  @override
  void onKeyboard(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        isDirectionalDown = true;
        currentDirectionalKey = event.logicalKey;
        joystickListener.joystickChangeDirectional(JoystickDirectionalEvent(
          directional: JoystickMoveDirectional.MOVE_DOWN,
          intensity: 1.0,
          radAngle: 0.0,
        ));
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        isDirectionalDown = true;
        currentDirectionalKey = event.logicalKey;
        joystickListener.joystickChangeDirectional(JoystickDirectionalEvent(
          directional: JoystickMoveDirectional.MOVE_UP,
          intensity: 1.0,
          radAngle: 0.0,
        ));
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        isDirectionalDown = true;
        currentDirectionalKey = event.logicalKey;
        joystickListener.joystickChangeDirectional(JoystickDirectionalEvent(
          directional: JoystickMoveDirectional.MOVE_LEFT,
          intensity: 1.0,
          radAngle: 0.0,
        ));
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        isDirectionalDown = true;
        currentDirectionalKey = event.logicalKey;
        joystickListener.joystickChangeDirectional(JoystickDirectionalEvent(
          directional: JoystickMoveDirectional.MOVE_RIGHT,
          intensity: 1.0,
          radAngle: 0.0,
        ));
      }

      if (!isDirectionalDown) {
        joystickListener.joystickAction(JoystickActionEvent(
          id: event.logicalKey.keyId,
        ));
      }
    } else if (event is RawKeyUpEvent &&
        isDirectionalDown &&
        currentDirectionalKey == event.logicalKey) {
      isDirectionalDown = false;
      joystickListener.joystickChangeDirectional(JoystickDirectionalEvent(
        directional: JoystickMoveDirectional.IDLE,
        intensity: 0.0,
        radAngle: 0.0,
      ));
    }
  }
}
