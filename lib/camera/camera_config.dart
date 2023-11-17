// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:bonfire/bonfire.dart';

enum InitialMapZoomFitEnum { none, fitWidth, fitHeight, fit }

/// Class use to configure camera behavior.
class CameraConfig {
  static final movementWindowDefault = Vector2.all(16);

  /// window in the center screen able to move without move camera
  Vector2 movementWindow;

  /// When this true the camera remains within the map area
  bool moveOnlyMapArea;

  /// Camera's speed
  double speed;

  /// Automatic zoom with base some configurations.
  InitialMapZoomFitEnum initialMapZoomFit;

  /// camera zoom configurarion. default: 1
  final double zoom;

  /// Camera angle to rotate the camera. default: 0
  final double angle;

  /// Component that the camera will focus on / follow
  final GameComponent? target;

  final bool startFollowPlayer;

  final Vector2? initPosition;

  final Vector2? resolution;

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
    this.resolution,
  }) : movementWindow = movementWindow ?? movementWindowDefault;

  CameraConfig copyWith({
    Vector2? movementWindow,
    bool? moveOnlyMapArea,
    double? zoom,
    double? angle,
    GameComponent? target,
    double? speed,
    bool? startFollowPlayer,
    InitialMapZoomFitEnum? initialMapZoomFit,
    Vector2? initPosition,
    Vector2? resolution,
  }) {
    return CameraConfig(
      movementWindow: movementWindow ?? this.movementWindow,
      moveOnlyMapArea: moveOnlyMapArea ?? this.moveOnlyMapArea,
      zoom: zoom ?? this.zoom,
      angle: angle ?? this.angle,
      target: target ?? this.target,
      speed: speed ?? this.speed,
      startFollowPlayer: startFollowPlayer ?? this.startFollowPlayer,
      initialMapZoomFit: initialMapZoomFit ?? this.initialMapZoomFit,
      initPosition: initPosition ?? this.initPosition,
      resolution: resolution ?? this.resolution,
    );
  }
}
