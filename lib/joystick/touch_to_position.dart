import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/joystick/joystick_controller.dart';
import 'package:flutter/gestures.dart';

class TouchToPosition extends JoystickController {
  int? _pointer;
  @override
  void render(Canvas c) {}

  @override
  void update(double t) {}

  @override
  void handlerPointerCancel(PointerCancelEvent event) {}

  @override
  void handlerPointerDown(PointerDownEvent event) {
    _pointer = event.pointer;
  }

  @override
  void handlerPointerMove(PointerMoveEvent event) {}

  @override
  void handlerPointerUp(PointerUpEvent event) {
    if (_pointer == event.pointer) {
      final absolutePosition = this
          .gameRef
          .gameCamera
          .screenPositionToWorld(event.position)
          .toVector2();
      moveTo(absolutePosition);
    }
  }

  @override
  bool hasGesture() {
    return true;
  }
}
