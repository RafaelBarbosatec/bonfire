import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/collision/object_collision.dart';
import 'package:bonfire/util/objects/animated_object.dart';
import 'package:flame/animation.dart' as FlameAnimation;
import 'package:flame/position.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/widgets.dart';

export 'package:bonfire/decoration/extensions.dart';

/// This component represents anything you want to add to the scene, it can be
/// a simple "barrel" halfway to an NPC that you can use to interact with your
/// player.
///
/// You can use ImageSprite or Animation[FlameAnimation.Animation]
class GameDecoration extends AnimatedObject with ObjectCollision {
  /// Height of the Decoration.
  final double height;

  /// Width of the Decoration.
  final double width;

  /// ImageSprite to draw.
  final String spriteImg;

  /// Use to define if this decoration should be drawing on the player.
  final bool frontFromPlayer;

  /// Use to define if this decoration contains collision.
  final bool withCollision;

  /// Animation[FlameAnimation.Animation] to draw.
  final FlameAnimation.Animation animation;

  /// World position that this decoration must position yourself.
  final Position initPosition;

  Sprite _sprite;

  GameDecoration(
      {this.spriteImg,
      @required this.initPosition,
      @required this.height,
      @required this.width,
      this.frontFromPlayer = false,
      this.animation,
      this.withCollision = false,
      Collision collision,
      bool isTouchable = false}) {
    this.animation = animation;
    if (spriteImg != null && spriteImg.isNotEmpty) _sprite = Sprite(spriteImg);
    this.position = this.positionInWorld = Rect.fromLTWH(
      initPosition.x,
      initPosition.y,
      width,
      height,
    );
    if (withCollision) {
      this.collision = collision ?? Collision(height: height, width: width);
    }
    this.isTouchable = isTouchable;
  }

  @override
  void update(double dt) {
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    if (isVisibleInMap()) {
      if (_sprite != null && _sprite.loaded())
        _sprite.renderRect(canvas, position);

      super.render(canvas);

      if (gameRef != null && gameRef.showCollisionArea) {
        drawCollision(canvas, position);
      }
    }
  }

  @override
  int priority() {
    if (frontFromPlayer) {
      return 15;
    } else {
      return super.priority();
    }
  }

  Rect get rectCollision => getRectCollision(position);
  Rect get rectCollisionInWorld => getRectCollision(positionInWorld);
}
