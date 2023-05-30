import 'package:bonfire/bonfire.dart';

class PlatformSpritesheet {
  static Future<SpriteAnimation> get enemyExplosion => SpriteAnimation.load(
        "platform/enemy-deadth.png",
        SpriteAnimationData.sequenced(
          amount: 6,
          stepTime: 0.08,
          textureSize: Vector2(40, 42),
        ),
      );

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

  static Future<SpriteAnimation> get frogIdleRight {
    return Sprite.load(
      "platform/frog/frog-idle.png",
      srcSize: Vector2(35, 32),
    ).then((value) {
      return SpriteAnimation.spriteList([value], stepTime: 1);
    });
  }

  static Future<SpriteAnimation> get frogActionRight => SpriteAnimation.load(
        "platform/frog/frog-idle.png",
        SpriteAnimationData.sequenced(
          amount: 4,
          stepTime: 0.1,
          textureSize: Vector2(35, 32),
        ),
      );

  static Future<SpriteAnimation> get frogJumpUp {
    return Sprite.load(
      "platform/frog/frog-jump.png",
      srcPosition: Vector2(35, 0),
      srcSize: Vector2(35, 32),
    ).then((value) {
      return SpriteAnimation.spriteList([value], stepTime: 1);
    });
  }

  static Future<SpriteAnimation> get frogJumpDown {
    return Sprite.load(
      "platform/frog/frog-jump.png",
      srcPosition: Vector2(70, 0),
      srcSize: Vector2(35, 32),
    ).then((value) {
      return SpriteAnimation.spriteList([value], stepTime: 1);
    });
  }

  static Future<SpriteAnimation> get gem => SpriteAnimation.load(
        "platform/gem.png",
        SpriteAnimationData.sequenced(
          amount: 5,
          stepTime: 0.1,
          textureSize: Vector2(15, 13),
        ),
      );

  static Future<SpriteAnimation> get itemFeedback => SpriteAnimation.load(
        "platform/item-feedback.png",
        SpriteAnimationData.sequenced(
          amount: 4,
          stepTime: 0.08,
          textureSize: Vector2(32, 32),
        ),
      );
}
