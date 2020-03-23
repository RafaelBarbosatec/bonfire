import 'dart:ui';

import 'package:bonfire/decoration/decoration.dart';
import 'package:bonfire/player/player.dart';
import 'package:bonfire/util/animated_object.dart';
import 'package:flame/animation.dart' as FlameAnimation;

/// This represents a Component for your game in bonfire.
///
/// All components like [Enemy],[Player] and [GameDecoration] extends this.
class PlayerObject extends AnimatedObject {
  /// Position used to draw on the screen
  Rect position;

  /// Position used to locate component in the world.
  ///
  /// This position takes into account the current position of the camera in the world.
  Rect _positionInWorld;

  /// Animation that will be drawn on the screen.
  FlameAnimation.Animation animation;

  /// Variable used to control whether the component has been destroyed.
  bool _isDestroyed = false;

  bool locked = false;

  @override
  void render(Canvas canvas) {
    if (animation == null) return;
    if (animation.loaded()) {
      animation.getSprite().renderRect(canvas, position);
    }
  }

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

  @override
  bool destroy() {
    return _isDestroyed;
  }

  /// This method destroy of the component
  void remove() {
    _isDestroyed = true;
  }

  /// This method verify if this component is in visible windows of the screen
  bool isVisibleInMap() {
    if (gameRef.size != null) {
      return position.top < (gameRef.size.height + position.height) &&
          position.top > (position.height * -1) &&
          position.left > (position.width * -1) &&
          position.left < (gameRef.size.width + position.width) &&
          !destroy();
    } else {
      return false;
    }
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
