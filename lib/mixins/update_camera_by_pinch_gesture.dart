import 'package:bonfire/bonfire.dart';

// Mixin usend in component that use PinchGesture to update zoom and
//cameraposition in pich gestures.
mixin UpdateCameraByPinchGesture on PinchGesture {
  double _initialZoom = 1.0;
  Vector2 _initialPosition = Vector2.zero();

  bool updateCameraByPinchGestureEnabled = true;

  @override
  void onPinchStart(PinchEvent event) {
    _initialZoom = gameRef.camera.zoom;
    _initialPosition = gameRef.camera.position.clone();
    super.onPinchStart(event);
  }

  @override
  void onPinchUpdate(PinchEvent event) {
    if (updateCameraByPinchGestureEnabled) {
      final scale = event.factorDistance;
      gameRef.camera.zoom = _initialZoom * scale;
      final diff = event.diffCenter;
      gameRef.camera.position = _initialPosition - diff / (gameRef.camera.zoom);
    }

    super.onPinchUpdate(event);
  }
}
