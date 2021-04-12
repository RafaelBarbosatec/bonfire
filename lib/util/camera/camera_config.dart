import 'dart:ui';

import 'package:bonfire/base/game_component.dart';

class CameraConfig {
  Size sizeMovementWindow;
  bool moveOnlyMapArea;
  double zoom;
  GameComponent? target;

  CameraConfig({
    this.sizeMovementWindow = const Size(50, 50),
    this.moveOnlyMapArea = false,
    this.zoom = 1.0,
    this.target,
  });
}
