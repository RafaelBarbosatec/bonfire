import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/objects/animated_object.dart';
import 'package:bonfire/util/priority_layer.dart';
import 'package:bonfire/util/vector2rect.dart';
import 'package:flame/extensions.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/widgets.dart';

export 'package:bonfire/decoration/extensions.dart';

/// This component represents anything you want to add to the scene, it can be
/// a simple "barrel" halfway to an NPC that you can use to interact with your
/// player.
///
/// You can use ImageSprite or Animation[FlameAnimation.Animation]
class GameDecoration extends AnimatedObject {
  /// Height of the Decoration.
  final double height;

  /// Width of the Decoration.
  final double width;

  /// Use to define if this decoration should be drawing on the player.
  final bool frontFromPlayer;

  Sprite sprite;

  int additionalPriority = 0;

  GameDecoration({
    this.sprite,
    @required Vector2 position,
    @required this.height,
    @required this.width,
    this.frontFromPlayer = false,
    SpriteAnimation animation,
  }) {
    this.animation = animation;
    this.position = generateRectWithBleedingPixel(
      position,
      width,
      height,
    );
  }

  GameDecoration.futureSprite(
    Future<Sprite> sprite, {
    @required Vector2 position,
    @required this.height,
    @required this.width,
    this.frontFromPlayer = false,
    SpriteAnimation animation,
  }) {
    sprite.then((value) => this.sprite = value);
    this.position = generateRectWithBleedingPixel(
      position,
      width,
      height,
    );
  }

  GameDecoration.sprite(
    this.sprite, {
    @required Vector2 position,
    @required this.height,
    @required this.width,
    this.frontFromPlayer = false,
  }) {
    this.position = generateRectWithBleedingPixel(
      position,
      width,
      height,
    );
  }

  GameDecoration.animation(
    SpriteAnimation animation, {
    @required Vector2 position,
    @required this.height,
    @required this.width,
    this.frontFromPlayer = false,
  }) {
    this.animation = animation;
    this.position = generateRectWithBleedingPixel(
      position,
      width,
      height,
    );
  }

  GameDecoration.futureAnimation(
    Future<SpriteAnimation> animation, {
    @required Vector2 position,
    @required this.height,
    @required this.width,
    this.frontFromPlayer = false,
  }) {
    animation.then((value) => this.animation = value);
    this.position = generateRectWithBleedingPixel(
      position,
      width,
      height,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    if (sprite?.loaded() == true) {
      sprite.renderFromVector2Rect(canvas, this.position);
    }
    super.render(canvas);
  }

  Vector2Rect generateRectWithBleedingPixel(
    Vector2 position,
    double width,
    double height,
  ) {
    double bleendingPixel = (width > height ? width : height) * 0.03;
    if (bleendingPixel > 2) {
      bleendingPixel = 2;
    }
    return Vector2Rect.fromRect(
      Rect.fromLTWH(
        position.x - (position.x % 2 == 0 ? (bleendingPixel / 2) : 0),
        position.y - (position.y % 2 == 0 ? (bleendingPixel / 2) : 0),
        width + (position.x % 2 == 0 ? bleendingPixel : 0),
        height + (position.y % 2 == 0 ? bleendingPixel : 0),
      ),
    );
  }

  @override
  int get priority {
    if (frontFromPlayer) {
      return PriorityLayer.OBJECTS;
    } else {
      return PriorityLayer.DECORATION + additionalPriority;
    }
  }
}
