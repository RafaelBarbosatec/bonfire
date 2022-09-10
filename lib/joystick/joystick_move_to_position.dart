import 'package:bonfire/bonfire.dart';
import 'package:flutter/gestures.dart';

class JoystickMoveToPosition extends JoystickController {
  final bool enabledMoveCameraWithClick;
  final MouseButton mouseButtonUsedToMoveCamera;
  final MouseButton mouseButtonUsedToMoveToPosition;
  int? _pointer;
  bool _initMove = false;
  bool _actionMoveToPosition = false;
  Vector2 _startPoint = Vector2.zero();
  Vector2 _startCameraPosition = Vector2.zero();

  JoystickMoveToPosition({
    this.enabledMoveCameraWithClick = false,
    this.mouseButtonUsedToMoveCamera = MouseButton.left,
    this.mouseButtonUsedToMoveToPosition = MouseButton.right,
  });

  @override
  bool handlerPointerDown(PointerDownEvent event) {
    _pointer = event.pointer;
    _startPoint = event.position.toVector2();
    _startCameraPosition = gameRef.camera.position;
    _actionMoveToPosition = _acceptFromMouse(
      event,
      mouseButtonUsedToMoveToPosition,
    );
    return super.handlerPointerDown(event);
  }

  @override
  bool handlerPointerMove(PointerMoveEvent event) {
    double distance = _startPoint.distanceTo(event.position.toVector2());
    if (distance > 1) {
      _initMove = true;

      if (enabledMoveCameraWithClick &&
          _acceptFromMouse(event, mouseButtonUsedToMoveCamera)) {
        double px = _startPoint.x - event.position.dx;
        double py = _startPoint.y - event.position.dy;
        gameRef.camera.target = null;
        gameRef.camera.snapTo(_startCameraPosition.translate(px, py));
      }
    }

    return super.handlerPointerMove(event);
  }

  @override
  bool handlerPointerUp(PointerUpEvent event) {
    if (_pointer == event.pointer && !_initMove && _actionMoveToPosition) {
      final absolutePosition = gameRef.screenToWorld(
        event.position.toVector2(),
      );
      moveTo(absolutePosition);
    }
    _initMove = false;
    return super.handlerPointerUp(event);
  }

  bool _acceptFromMouse(PointerEvent event, MouseButton button) {
    bool isMouse = event.kind == PointerDeviceKind.mouse;

    if (!isMouse) {
      return true;
    }
    if (event.buttons == _getButtonByEnum(button)) {
      return true;
    }
    return false;
  }

  int _getButtonByEnum(MouseButton button) {
    switch (button) {
      case MouseButton.left:
        return 1;
      case MouseButton.right:
        return 2;
      case MouseButton.middle:
        return 4;
      case MouseButton.unknow:
        return 0;
    }
  }
}
