import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/joystick/joystick_controller.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class JoystickMoveToPosition extends JoystickController {
  int? _pointer;
  bool _interfaceReceiveInteraction = false;

  @override
  void render(Canvas c) {}

  @override
  void update(double t) {}

  @override
  void handlerPointerDown(PointerDownEvent event) {
    _pointer = event.pointer;
    super.handlerPointerDown(event);
    _interfaceReceiveInteraction =
        gameRef.interface?.receiveInteraction ?? false;
  }

  @override
  void handlerPointerUp(PointerUpEvent event) {
    if (_pointer == event.pointer) {
      if (!_interfaceReceiveInteraction) {
        final absolutePosition =
            this.gameRef.screenPositionToWorld(event.position);
        moveTo(absolutePosition.toVector2());
      }
    }
    _interfaceReceiveInteraction = false;
    super.handlerPointerUp(event);
  }
}
