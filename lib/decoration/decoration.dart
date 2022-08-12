import 'dart:async';

import 'package:bonfire/bonfire.dart';

/// This component represents anything you want to add to the scene, it can be
/// a simple "barrel" halfway to an NPC that you can use to interact with your
/// player.
///
/// You can use ImageSprite or Animation[FlameAnimation.Animation]
class GameDecoration extends GameComponent
    with UseSpriteAnimation, Vision, UseSprite, UseAssetsLoader {
  GameDecoration({
    required Vector2 position,
    required Vector2 size,
    Sprite? sprite,
    SpriteAnimation? animation,
  }) {
    this.sprite = sprite;
    this.animation = animation;
    applyBleedingPixel(position: position, size: size);
  }

  GameDecoration.withSprite({
    required FutureOr<Sprite> sprite,
    required Vector2 position,
    required Vector2 size,
  }) {
    loader?.add(AssetToLoad(sprite, (value) => this.sprite = value));
    applyBleedingPixel(position: position, size: size);
  }

  GameDecoration.withAnimation({
    required FutureOr<SpriteAnimation> animation,
    required Vector2 position,
    required Vector2 size,
  }) {
    loader?.add(AssetToLoad(animation, (value) => this.animation = value));
    applyBleedingPixel(position: position, size: size);
  }
}
