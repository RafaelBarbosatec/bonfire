import 'dart:async';
import 'dart:ui';

import 'package:bonfire/bonfire.dart';

/// This component represents anything you want to add to the scene, it can be
/// a simple "barrel" halfway to an NPC that you can use to interact with your
/// player.
///
/// You can use ImageSprite or Animation[FlameAnimation.Animation]
class GameDecoration extends AnimatedGameObject {
  GameDecoration({
    required super.position,
    required super.size,
    Sprite? sprite,
    SpriteAnimation? animation,
    super.anchor,
    super.angle,
    super.lightingConfig,
    super.renderAboveComponents,
  }) {
    this.sprite = sprite;
    setAnimation(animation);
    applyBleedingPixel(position: position, size: size);
  }

  GameDecoration.withSprite({
    required FutureOr<Sprite> sprite,
    required super.position,
    required super.size,
    super.anchor,
    super.angle,
    super.lightingConfig,
    super.renderAboveComponents,
  }) {
    loader?.add(
      AssetToLoad<Sprite>(sprite, (value) => this.sprite = value),
    );
    applyBleedingPixel(position: position, size: size);
  }

  GameDecoration.withAnimation({
    required FutureOr<SpriteAnimation> animation,
    required super.position,
    required super.size,
    super.anchor,
    super.angle,
    super.lightingConfig,
    super.renderAboveComponents,
  }) {
    loader?.add(AssetToLoad<SpriteAnimation>(animation, setAnimation));
    applyBleedingPixel(position: position, size: size);
  }

  @override
  Future playSpriteAnimationOnce(
    FutureOr<SpriteAnimation> animation, {
    Vector2? size,
    Vector2? offset,
    VoidCallback? onFinish,
    VoidCallback? onStart,
    bool loop = false,
  }) {
    return super.playSpriteAnimationOnce(
      animation,
      size: size,
      offset: offset,
      loop: loop,
      onFinish: onFinish,
      onStart: () {
        onStart?.call();
      },
    );
  }
}
