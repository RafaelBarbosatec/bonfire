import 'package:bonfire/bonfire.dart';

/// Class use to configure camera behavior.
class CameraConfig {
  static final movementWindowDefault = Vector2.all(32);

  Vector2 movementWindow;

  /// When this true the camera remains within the map area
  bool moveOnlyMapArea;

  /// camera zoom configurarion. default: 1
  double zoom;

  /// Camera angle to rotate the camera. default: 0
  double angle;

  /// Component that the camera will focus on / follow
  GameComponent? target;

  double speed;

  bool setZoomLimitToFitMap;

  CameraConfig({
    this.moveOnlyMapArea = false,
    this.zoom = 1.0,
    this.angle = 0.0,
    this.target,
    this.speed = double.infinity,
    this.setZoomLimitToFitMap = false,
    Vector2? movementWindow,
  }) : movementWindow = movementWindow ?? movementWindowDefault;
}
