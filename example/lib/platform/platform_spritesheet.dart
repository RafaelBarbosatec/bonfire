import 'package:bonfire/bonfire.dart';

class PlatformSpritesheet {
  static Future<SpriteAnimation> get playerIdleRight => SpriteAnimation.load(
        "platform/fox/player-idle.png",
        SpriteAnimationData.sequenced(
          amount: 4,
          stepTime: 0.2,
          textureSize: Vector2(33, 32),
        ),
      );

  static Future<SpriteAnimation> get playerRunRight => SpriteAnimation.load(
        "platform/fox/player-run.png",
        SpriteAnimationData.sequenced(
          amount: 6,
          stepTime: 0.1,
          textureSize: Vector2(33, 32),
        ),
      );

  static Future<SpriteAnimation> get playerJumpUp {
    return Sprite.load("platform/fox/player-jump.png", srcSize: Vector2(33, 32))
        .then((value) {
      return SpriteAnimation.spriteList([value], stepTime: 1);
    });
  }

  static Future<SpriteAnimation> get playerJumpDown {
    return Sprite.load("platform/fox/player-jump.png",
            srcPosition: Vector2(33, 0), srcSize: Vector2(33, 32))
        .then((value) {
      return SpriteAnimation.spriteList([value], stepTime: 1);
    });
  }
}
