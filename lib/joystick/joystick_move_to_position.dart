import 'package:bonfire/bonfire.dart';
import 'package:flutter/gestures.dart';

enum MouseButton { primary, secondary, tertiary }

class JoystickMoveToPosition extends JoystickController {
  final bool enabledMoveCameraWithClick;
  final MouseButton mouseButtonUsedToMoveCamera;
  final MouseButton mouseButtonUsedToMoveToPosition;
  int? _pointer;
  bool _interfaceReceiveInteraction = false;
  bool _initMove = false;
  bool _actionMoveToPosition = false;
  Vector2 _startPoint = Vector2.zero();
  Vector2 _startCameraPosition = Vector2.zero();

  JoystickMoveToPosition({
    this.enabledMoveCameraWithClick = false,
    this.mouseButtonUsedToMoveCamera = MouseButton.primary,
    this.mouseButtonUsedToMoveToPosition = MouseButton.secondary,
  });

  @override
  void handlerPointerDown(PointerDownEvent event) {
    _pointer = event.pointer;
    _startPoint = event.position.toVector2();
    _startCameraPosition = gameRef.camera.position;
    _actionMoveToPosition = _acceptFromMouse(
      event,
      mouseButtonUsedToMoveToPosition,
    );
    super.handlerPointerDown(event);
    _interfaceReceiveInteraction =
        gameRef.interface?.receiveInteraction ?? false;
  }

  @override
  void handlerPointerMove(PointerMoveEvent event) {
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

    super.handlerPointerMove(event);
  }

  @override
  void handlerPointerUp(PointerUpEvent event) {
    if (_pointer == event.pointer && !_initMove && _actionMoveToPosition) {
      if (!_interfaceReceiveInteraction) {
        final absolutePosition =
            this.gameRef.screenToWorld(event.position.toVector2());
        moveTo(absolutePosition);
      }
    }
    _interfaceReceiveInteraction = false;
    _initMove = false;
    super.handlerPointerUp(event);
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
      case MouseButton.primary:
        return 1;
      case MouseButton.secondary:
        return 2;
      case MouseButton.tertiary:
        return 4;
    }
  }
}
