import 'package:bonfire/bonfire.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class JoystickMoveToPosition extends JoystickController {
  int? _pointer;
  bool _interfaceReceiveInteraction = false;

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
            this.gameRef.screenToWorld(event.position.toVector2());
        moveTo(absolutePosition);
      }
    }
    _interfaceReceiveInteraction = false;
    super.handlerPointerUp(event);
  }
}
