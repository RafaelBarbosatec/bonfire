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

  /// Use to define if this decoration should be drawing on the player.
  final bool frontFromPlayer;

  /// World position that this decoration must position yourself.
  final Position initPosition;

  /// If set to true, won't be triggered on collision, but will trigger onContact()
  final bool isSensor;

  Sprite _sprite;

  GameDecoration({
    Sprite sprite,
    @required this.initPosition,
    @required this.height,
    @required this.width,
    this.frontFromPlayer = false,
    this.isSensor = false,
    FlameAnimation.Animation animation,
    Collision collision,
    bool isTouchable = false,
  }) {
    this.animation = animation;
    _sprite = sprite;
    this.position = generateRectWithBleedingPixel(
      initPosition,
      width,
      height,
    );
    this.collision = collision;
    this.isTouchable = isTouchable;
  }

  GameDecoration.sprite(
    Sprite sprite, {
    @required this.initPosition,
    @required this.height,
    @required this.width,
    this.frontFromPlayer = false,
    this.isSensor = false,
    Collision collision,
    bool isTouchable = false,
  }) {
    _sprite = sprite;
    this.position = generateRectWithBleedingPixel(
      initPosition,
      width,
      height,
    );
    this.collision = collision;
    this.isTouchable = isTouchable;
  }

  GameDecoration.animation(
    FlameAnimation.Animation animation, {
    @required this.initPosition,
    @required this.height,
    @required this.width,
    this.isSensor = false,
    this.frontFromPlayer = false,
    Collision collision,
    bool isTouchable = false,
  }) {
    this.animation = animation;
    this.position = generateRectWithBleedingPixel(
      initPosition,
      width,
      height,
    );
    this.collision = collision;
    this.isTouchable = isTouchable;
  }

  @override
  void update(double dt) {
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    if (isVisibleInCamera()) {
      if (_sprite != null && _sprite.loaded())
        _sprite.renderRect(canvas, position);

      super.render(canvas);

      if (gameRef != null && gameRef.showCollisionArea) {
        drawCollision(canvas, position, gameRef.collisionAreaColor);
      }
    }
  }

  void onContact(ObjectCollision collision) {}

  Rect generateRectWithBleedingPixel(
    Position position,
    double width,
    double height,
  ) {
    double bleendingPixel = (width > height ? width : height) * 0.03;
    if (bleendingPixel > 2) {
      bleendingPixel = 2;
    }
    return Rect.fromLTWH(
      position.x - (position.x % 2 == 0 ? (bleendingPixel / 2) : 0),
      position.y - (position.y % 2 == 0 ? (bleendingPixel / 2) : 0),
      width + (position.x % 2 == 0 ? bleendingPixel : 0),
      height + (position.y % 2 == 0 ? bleendingPixel : 0),
    );
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
}
