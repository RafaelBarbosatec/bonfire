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
  void onPointerDown(PointerDownEvent event) {
    position = event.position;
    super.onPointerDown(event);
  }

  @override
  void onPointerUp(PointerUpEvent event) {
    if (position == event.position) {
      final absolutePosition = this.gameRef.gameCamera.screenPositionToWorld(event.position);
      moveTo(Position.fromOffset(absolutePosition));
    }
  }
}
