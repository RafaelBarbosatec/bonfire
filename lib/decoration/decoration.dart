import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/assets_loader.dart';
import 'package:flame/extensions.dart';

/// This component represents anything you want to add to the scene, it can be
/// a simple "barrel" halfway to an NPC that you can use to interact with your
/// player.
///
/// You can use ImageSprite or Animation[FlameAnimation.Animation]
class GameDecoration extends AnimatedObject {
  Sprite? sprite;

  /// Used to load assets in [onLoad]
  final _loader = AssetsLoader();

  GameDecoration({
    this.sprite,
    required Vector2 position,
    required double height,
    required double width,
    SpriteAnimation? animation,
  }) {
    this.animation = animation;
    this.position = generateRectWithBleedingPixel(
      position,
      width,
      height,
    );
  }

  GameDecoration.withSprite(
    FutureOr<Sprite> sprite, {
    required Vector2 position,
    required double height,
    required double width,
  }) {
    _loader.add(AssetToLoad(sprite, (value) => this.sprite = value));
    this.position = generateRectWithBleedingPixel(
      position,
      width,
      height,
    );
  }

  GameDecoration.withAnimation(
    FutureOr<SpriteAnimation> animation, {
    required Vector2 position,
    required double height,
    required double width,
  }) {
    _loader.add(AssetToLoad(animation, (value) => this.animation = value));
    this.position = generateRectWithBleedingPixel(
      position,
      width,
      height,
    );
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    sprite?.renderFromVector2Rect(
      canvas,
      this.position,
      opacity: opacity,
    );
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
  Future<void> onLoad() async {
    await super.onLoad();
    return _loader.load();
  }
}
