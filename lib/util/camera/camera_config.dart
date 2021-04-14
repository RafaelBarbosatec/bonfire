import 'dart:ui';

import 'package:bonfire/base/game_component.dart';

/// Class use to configure camera behavior.
class CameraConfig {
  ///Player movement window before the camera moves
  Size sizeMovementWindow;

  /// When this true the camera remains within the map area
  bool moveOnlyMapArea;

  /// camera zoom configurarion. default: 1
  double zoom;

  /// Component that the camera will focus on / follow
  GameComponent? target;

  CameraConfig({
    this.sizeMovementWindow = const Size(50, 50),
    this.moveOnlyMapArea = false,
    this.zoom = 1.0,
    this.target,
  });
}
