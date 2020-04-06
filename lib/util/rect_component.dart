import 'dart:ui';

import 'package:bonfire/rpg_game.dart';
import 'package:flame/components/component.dart';
import 'package:flame/components/mixins/has_game_ref.dart';

abstract class RectComponent extends Component with HasGameRef<RPGGame> {
  /// Position used to draw on the screen
  Rect position;

  /// Position used to locate component in the world.
  ///
  /// This position takes into account the current position of the camera in the world.
  Rect positionInWorld;

  /// Variable used to control whether the component has been destroyed.
  bool _isDestroyed = false;

  @override
  void render(Canvas c) {
    // TODO: implement render
  }

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
      positionInWorld.left + gameRef.gameCamera.position.x,
      positionInWorld.top + gameRef.gameCamera.position.y,
      positionInWorld.width,
      positionInWorld.height,
    );
  }
}
