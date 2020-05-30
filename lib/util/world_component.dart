import 'dart:ui';

import 'package:bonfire/util/game_component.dart';

abstract class WorldComponent extends GameComponent {
  /// Position used to locate component in the world.
  ///
  /// This position takes into account the current position of the camera in the world.
  Rect positionInWorld;

  /// Variable used to control whether the component has been destroyed.
  bool _isDestroyed = false;

  @override
  void render(Canvas c) {}

  @override
  void update(double t) {
    position ??= positionInWorld ?? Rect.zero;
  }

  @override
  bool destroy() {
    return _isDestroyed;
  }

  /// This method destroy of the component
  void remove() {
    _isDestroyed = true;
  }

  bool isVisibleInMap() {
    if (gameRef?.size == null || position == null || destroy() == true)
      return false;

    final cameraRect = Rect.fromLTWH(
      gameRef.gameCamera.position.x,
      gameRef.gameCamera.position.y,
      gameRef.size.width,
      gameRef.size.height,
    );

    return position.overlaps(cameraRect);
  }
}
