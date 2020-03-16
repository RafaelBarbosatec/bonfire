import 'dart:ui';

import 'package:bonfire/rpg_game.dart';
import 'package:bonfire/util/animated_object.dart';
import 'package:flame/animation.dart' as FlameAnimation;
import 'package:flame/components/mixins/has_game_ref.dart';
import 'package:flame/position.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/widgets.dart';

export 'package:bonfire/decoration/extensions.dart';

class GameDecoration extends AnimatedObject with HasGameRef<RPGGame> {
  final double height;
  final double width;
  final String spriteImg;
  final bool frontFromPlayer;
  final bool collision;
  final FlameAnimation.Animation animation;
  final Position initPosition;
  Sprite _sprite;
  Rect positionInWorld;

  GameDecoration({
    this.spriteImg,
    @required this.initPosition,
    @required this.height,
    @required this.width,
    this.frontFromPlayer = false,
    this.animation,
    this.collision = false,
  }) {
    this.animation = animation;
    if (spriteImg != null && spriteImg.isNotEmpty) _sprite = Sprite(spriteImg);
    position = Rect.fromLTWH(
      initPosition.x,
      initPosition.y,
      width,
      height,
    );
    positionInWorld = position;
  }

  @override
  void update(double dt) {
    position = Rect.fromLTWH(
      positionInWorld.left + gameRef.mapCamera.x,
      positionInWorld.top + gameRef.mapCamera.y,
      width,
      height,
    );
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    if (isVisibleInMap()) {
      super.render(canvas);
      if (_sprite != null && _sprite.loaded())
        _sprite.renderRect(canvas, position);
    }
  }

  @override
  int priority() {
    if (frontFromPlayer) {
      return 1;
    } else {
      return super.priority();
    }
  }

  bool isVisibleInMap() {
    if (gameRef.size != null) {
      return position.top < (gameRef.size.height + height) &&
          position.top > (height * -1) &&
          position.left > (width * -1) &&
          position.left < (gameRef.size.width + width) &&
          !destroy();
    } else {
      return false;
    }
  }
}
