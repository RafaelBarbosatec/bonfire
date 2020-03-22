import 'dart:ui';

import 'package:bonfire/decoration/decoration.dart';
import 'package:bonfire/player/player.dart';
import 'package:bonfire/rpg_game.dart';
import 'package:flame/animation.dart' as FlameAnimation;
import 'package:flame/components/component.dart';
import 'package:flame/components/mixins/has_game_ref.dart';

/// This represents a Component for your game in bonfire.
///
/// All components like [Enemy],[Player] and [GameDecoration] extends this.
class AnimatedObject extends Component with HasGameRef<RPGGame> {
  /// Position used to draw on the screen
  Rect position;

  /// Position used to locate component in the world.
  ///
  /// This position takes into account the current position of the camera in the world.
  Rect positionInWorld;

  /// Animation that will be drawn on the screen.
  FlameAnimation.Animation animation;

  /// Variable used to control whether the component has been destroyed.
  bool _isDestroyed = false;

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
      positionInWorld.left + gameRef.mapCamera.position.x,
      positionInWorld.top + gameRef.mapCamera.position.y,
      positionInWorld.width,
      positionInWorld.height,
    );
  }
}
