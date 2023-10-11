import 'package:bonfire/bonfire.dart';

enum InitialMapZoomFitEnum { none, fitWidth, fitHeight, fit }

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

  final Vector2? initPosition;

  CameraConfig({
    this.moveOnlyMapArea = false,
    this.startFollowPlayer = true,
    this.zoom = 1.0,
    this.angle = 0.0,
    this.target,
    this.speed = 5, // no smoth speed sets double.infinity
    this.initialMapZoomFit = InitialMapZoomFitEnum.none,
    this.initPosition,
    Vector2? movementWindow,
  }) : movementWindow = movementWindow ?? movementWindowDefault;
}
