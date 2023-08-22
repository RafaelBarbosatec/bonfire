import 'package:bonfire/bonfire.dart';

enum InitialMapZoomFitEnum { none, fitWidth, fitHeight, cover }

/// Class use to configure camera behavior.
class CameraConfig {
  static final movementWindowDefault = Vector2.all(16);

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

  bool startFollowPlayer;

  InitialMapZoomFitEnum initialMapZoomFit;

  CameraConfig({
    this.moveOnlyMapArea = false,
    this.startFollowPlayer = true,
    this.zoom = 1.0,
    this.angle = 0.0,
    this.target,
    this.speed = double.infinity,
    this.initialMapZoomFit = InitialMapZoomFitEnum.none,
    Vector2? movementWindow,
  }) : movementWindow = movementWindow ?? movementWindowDefault;
}
