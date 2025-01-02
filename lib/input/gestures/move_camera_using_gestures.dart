import 'package:bonfire/bonfire.dart';
import 'package:flutter/gestures.dart';

/// Mixin used to move camera with gestures (touch or mouse)
mixin MoveCameraUsingGesture on GameComponent {
  Vector2 _startPoint = Vector2.zero();
  Vector2 _startCameraPosition = Vector2.zero();
  bool _onlyMouse = false;
  MouseButton _mouseButton = MouseButton.left;

  void setupMoveCameraUsingGesture({
    bool onlyMouse = false,
    MouseButton mouseButton = MouseButton.left,
  }) {
    _mouseButton = mouseButton;
    _onlyMouse = onlyMouse;
  }

  @override
  bool handlerPointerDown(PointerDownEvent event) {
    _startPoint = event.position.toVector2();
    _startCameraPosition = gameRef.camera.position;
    return super.handlerPointerDown(event);
  }

  @override
  bool handlerPointerMove(PointerMoveEvent event) {
    final distance = _startPoint.distanceTo(event.position.toVector2());
    if (distance > 1) {
      if (_acceptGesture(event, _mouseButton)) {
        final zoom = gameRef.camera.zoom;
        final px = _startPoint.x - event.position.dx;
        final py = _startPoint.y - event.position.dy;
        gameRef.camera.stop();
        gameRef.camera.moveTo(
          _startCameraPosition.translated(
            px / zoom,
            py / zoom,
          ),
        );
      }
    }

    return super.handlerPointerMove(event);
  }

  bool _acceptGesture(PointerEvent event, MouseButton button) {
    final isMouse = event.kind == PointerDeviceKind.mouse;

    if (_onlyMouse) {
      return event.buttons == button.id && isMouse;
    } else {
      if (isMouse) {
        return event.buttons == button.id;
      }
      return true;
    }
  }

  @override
  bool hasGesture() => true;

  @override
  bool get isVisible => true;
}
