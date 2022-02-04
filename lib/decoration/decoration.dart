import 'dart:async';
import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/assets_loader.dart';

/// This component represents anything you want to add to the scene, it can be
/// a simple "barrel" halfway to an NPC that you can use to interact with your
/// player.
///
/// You can use ImageSprite or Animation[FlameAnimation.Animation]
class GameDecoration extends GameComponent
    with WithSpriteAnimation, WithSprite, WithAssetsLoader {
  GameDecoration({
    Sprite? sprite,
    required Vector2 position,
    required Vector2 size,
    SpriteAnimation? animation,
  }) {
    this.sprite = sprite;
    this.animation = animation;
    generateRectWithBleedingPixel(
      position,
      size,
    );
  }

  GameDecoration.withSprite({
    required FutureOr<Sprite> sprite,
    required Vector2 position,
    required Vector2 size,
  }) {
    loader?.add(AssetToLoad(sprite, (value) => this.sprite = value));
    generateRectWithBleedingPixel(
      position,
      size,
    );
  }

  GameDecoration.withAnimation({
    required FutureOr<SpriteAnimation> animation,
    required Vector2 position,
    required Vector2 size,
  }) {
    loader?.add(AssetToLoad(animation, (value) => this.animation = value));
    generateRectWithBleedingPixel(
      position,
      size,
    );
  }

  void generateRectWithBleedingPixel(
    Vector2 position,
    Vector2 size,
  ) {
    double bleendingPixel = max(size.x, size.y) * 0.03;
    if (bleendingPixel > 2) {
      bleendingPixel = 2;
    }
    this.position = Vector2(
      position.x - (position.x % 2 == 0 ? (bleendingPixel / 2) : 0),
      position.y - (position.y % 2 == 0 ? (bleendingPixel / 2) : 0),
    );
    this.size = Vector2(
      size.x + (position.x % 2 == 0 ? bleendingPixel : 0),
      size.y + (position.y % 2 == 0 ? bleendingPixel : 0),
    );
  }
}
