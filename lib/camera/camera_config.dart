import 'package:bonfire/base/game_component.dart';
import 'package:flame/components.dart';

/// Class use to configure camera behavior.
class CameraConfig {
  static final sizeWidowsDefault = Vector2(16, 16);

  ///Player movement window before the camera moves
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
    Vector2? sizeMovementWindow,
    this.moveOnlyMapArea = false,
    this.zoom = 1.0,
    this.angle = 0.0,
    this.target,
    this.speed = double.infinity,
    this.setZoomLimitToFitMap = false,
  }) : movementWindow = sizeMovementWindow ?? sizeWidowsDefault;
}
