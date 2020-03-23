import 'dart:ui';

import 'package:bonfire/util/animated_object.dart';

/// This represents a Component player for your game in bonfire.
class PlayerObject extends AnimatedObject {
  /// Position used to locate component in the world.
  ///
  /// This position takes into account the current position of the camera in the world.
  Rect _positionInWorld;

  bool locked = false;

  @override
  void update(double dt) {
    if (animation != null) animation.update(dt);
    if (locked) {
      position = positionInWordToPosition();
    }
  }

  void lockPositionInWorld() {
    _positionInWorld = Rect.fromLTWH(
      position.left - gameRef.mapCamera.position.x,
      position.top - gameRef.mapCamera.position.y,
      position.width,
      position.height,
    );
    locked = true;
  }

  void unlockPositionInWorld() {
    locked = false;
  }

  Rect positionInWordToPosition() {
    return Rect.fromLTWH(
      _positionInWorld.left + gameRef.mapCamera.position.x,
      _positionInWorld.top + gameRef.mapCamera.position.y,
      _positionInWorld.width,
      _positionInWorld.height,
    );
  }
}
