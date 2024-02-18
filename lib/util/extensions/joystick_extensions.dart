import 'dart:math';

import 'package:bonfire/input/player_controller.dart';

extension JoystickDirectionalEventExtention on JoystickDirectionalEvent {
  double get directionalRadAngle {
    return directional.radAngle;
  }
}

extension JoystickMoveDirectionalExt on JoystickMoveDirectional {
  double get radAngle {
    switch (this) {
      case JoystickMoveDirectional.MOVE_LEFT:
        return 180 / (180 / pi);
      case JoystickMoveDirectional.MOVE_RIGHT:
        // we can't use 0 here because then no movement happens
        // we're just going as close to 0.0 without being exactly 0.0
        // if you have a better idea. Please be my guest
        return 0.0000001 / (180 / pi);
      case JoystickMoveDirectional.MOVE_UP:
        return -90 / (180 / pi);
      case JoystickMoveDirectional.MOVE_DOWN:
        return 90 / (180 / pi);
      case JoystickMoveDirectional.MOVE_UP_LEFT:
        return -135 / (180 / pi);
      case JoystickMoveDirectional.MOVE_UP_RIGHT:
        return -45 / (180 / pi);
      case JoystickMoveDirectional.MOVE_DOWN_LEFT:
        return 135 / (180 / pi);
      case JoystickMoveDirectional.MOVE_DOWN_RIGHT:
        return 45 / (180 / pi);
      default:
        return 0;
    }
  }
}
