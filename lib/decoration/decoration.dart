import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/objects/animated_object.dart';
import 'package:bonfire/util/collision/object_collision.dart';
import 'package:bonfire/util/priority_layer.dart';
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

  Sprite _sprite;

  int additionalPriority = 0;

  GameDecoration({
    Sprite sprite,
    @required this.initPosition,
    @required this.height,
    @required this.width,
    this.frontFromPlayer = false,
    FlameAnimation.Animation animation,
    Collision collision,
  }) {
    if (frontFromPlayer) additionalPriority = 1;
    this.animation = animation;
    _sprite = sprite;
    this.position = generateRectWithBleedingPixel(
      initPosition,
      width,
      height,
    );
    if (collision != null) this.collisions = [collision];
  }

  GameDecoration.sprite(
    Sprite sprite, {
    @required this.initPosition,
    @required this.height,
    @required this.width,
    this.frontFromPlayer = false,
    Collision collision,
  }) {
    if (frontFromPlayer) additionalPriority = 1;
    _sprite = sprite;
    this.position = generateRectWithBleedingPixel(
      initPosition,
      width,
      height,
    );
    if (collision != null) this.collisions = [collision];
  }

  GameDecoration.animation(
    FlameAnimation.Animation animation, {
    @required this.initPosition,
    @required this.height,
    @required this.width,
    this.frontFromPlayer = false,
    Collision collision,
  }) {
    if (frontFromPlayer) additionalPriority = 1;
    this.animation = animation;
    this.position = generateRectWithBleedingPixel(
      initPosition,
      width,
      height,
    );
    if (collision != null) this.collisions = [collision];
  }

  GameDecoration.spriteMultiCollision(
    Sprite sprite, {
    @required this.initPosition,
    @required this.height,
    @required this.width,
    this.frontFromPlayer = false,
    List<Collision> collisions,
  }) {
    if (frontFromPlayer) additionalPriority = 1;
    _sprite = sprite;
    this.position = generateRectWithBleedingPixel(
      initPosition,
      width,
      height,
    );
    this.collisions = collisions;
  }

  GameDecoration.animationMultiCollision(
    FlameAnimation.Animation animation, {
    @required this.initPosition,
    @required this.height,
    @required this.width,
    this.frontFromPlayer = false,
    List<Collision> collisions,
  }) {
    if (frontFromPlayer) additionalPriority = 1;
    this.animation = animation;
    this.position = generateRectWithBleedingPixel(
      initPosition,
      width,
      height,
    );
    this.collisions = collisions;
  }

  @override
  void update(double dt) {
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    if (_sprite != null && _sprite.loaded())
      _sprite.renderRect(canvas, position);

    super.render(canvas);

    if (gameRef != null && gameRef.showCollisionArea) {
      drawCollision(canvas, position, gameRef.collisionAreaColor);
    }
  }

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
    if (additionalPriority == 0) {
      return PriorityLayer.DECORATION;
    } else {
      return PriorityLayer.OBJECTS + additionalPriority;
    }
  }
}
