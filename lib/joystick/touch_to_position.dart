import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/joystick/joystick_controller.dart';
import 'package:flutter/gestures.dart';

class TouchToPosition extends JoystickController {
  Offset position;
  @override
  void render(Canvas c) {}

  @override
  void update(double t) {}

  @override
  void onTapDown(int pointerId, TapDownDetails details) {
    position = details.localPosition;
    super.onTapDown(pointerId, details);
  }

  @override
  void onTapUp(int pointerId, TapUpDetails details) {
    if (position == details.localPosition) {
      final absolutePosition = this
          .gameRef
          .gameCamera
          .screenPositionToWorld(details.localPosition)
          .toVector2();
      moveTo(absolutePosition);
    }
    super.onTapUp(pointerId, details);
  }
}
