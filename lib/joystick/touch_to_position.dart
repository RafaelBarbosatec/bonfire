import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/joystick/joystick_controller.dart';
import 'package:flutter/gestures.dart';

class TouchToPosition extends JoystickController {
  @override
  void render(Canvas c) {}

  @override
  void update(double t) {}

  @override
  void onPointerUp(PointerUpEvent event) {
    final absolutePosition = this.gameRef.gameCamera.cameraPositionToWorld(event.position);
    moveTo(Position.fromOffset(absolutePosition));
  }
}
