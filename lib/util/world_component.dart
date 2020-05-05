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
    position = positionInWordToPosition();
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
    if (gameRef == null || gameRef.size == null || position == null)
      return false;

    return position.top < (gameRef.size.height + position.height) &&
        position.top > (position.height * -1) &&
        position.left > (position.width * -1) &&
        position.left < (gameRef.size.width + position.width) &&
        !destroy();
  }

  Rect positionInWordToPosition() {
    if (positionInWorld == null) return Rect.zero;
    if (gameRef == null) return positionInWorld;
    return Rect.fromLTWH(
      positionInWorld.left + gameRef.gameCamera.position.x,
      positionInWorld.top + gameRef.gameCamera.position.y,
      positionInWorld.width,
      positionInWorld.height,
    );
  }
}
