import 'package:bonfire/bonfire.dart';

class CommonSpriteSheet {
  static Future<SpriteAnimation> get explosionAnimation => SpriteAnimation.load(
        "player/explosion_fire.png",
        SpriteAnimationData.sequenced(
          amount: 6,
          stepTime: 0.1,
          textureSize: Vector2(32, 32),
        ),
      );

  static Future<SpriteAnimation> get emote => SpriteAnimation.load(
        "player/emote_exclamacao.png",
        SpriteAnimationData.sequenced(
          amount: 8,
          stepTime: 0.1,
          textureSize: Vector2(32, 32),
        ),
      );
  static Future<SpriteAnimation> get smokeExplosion => SpriteAnimation.load(
        "smoke_explosion.png",
        SpriteAnimationData.sequenced(
          amount: 6,
          stepTime: 0.1,
          textureSize: Vector2(16, 16),
        ),
      );

  static Future<SpriteAnimation> get whiteAttackEffectBottom =>
      SpriteAnimation.load(
        "player/attack_effect_bottom.png",
        SpriteAnimationData.sequenced(
          amount: 6,
          stepTime: 0.1,
          textureSize: Vector2(16, 16),
        ),
      );

  static Future<SpriteAnimation> get whiteAttackEffectLeft =>
      SpriteAnimation.load(
        "player/attack_effect_left.png",
        SpriteAnimationData.sequenced(
          amount: 6,
          stepTime: 0.1,
          textureSize: Vector2(16, 16),
        ),
      );

  static Future<SpriteAnimation> get whiteAttackEffectRight =>
      SpriteAnimation.load(
        "player/attack_effect_right.png",
        SpriteAnimationData.sequenced(
          amount: 6,
          stepTime: 0.1,
          textureSize: Vector2(16, 16),
        ),
      );

  static Future<SpriteAnimation> get whiteAttackEffectTop =>
      SpriteAnimation.load(
        "player/attack_effect_top.png",
        SpriteAnimationData.sequenced(
          amount: 6,
          stepTime: 0.1,
          textureSize: Vector2(16, 16),
        ),
      );

  static Future<SpriteAnimation> get blackAttackEffectBottom =>
      SpriteAnimation.load(
        "enemy/attack_effect_bottom.png",
        SpriteAnimationData.sequenced(
          amount: 6,
          stepTime: 0.1,
          textureSize: Vector2(16, 16),
        ),
      );

  static Future<SpriteAnimation> get blackAttackEffectLeft =>
      SpriteAnimation.load(
        "enemy/attack_effect_left.png",
        SpriteAnimationData.sequenced(
          amount: 6,
          stepTime: 0.1,
          textureSize: Vector2(16, 16),
        ),
      );

  static Future<SpriteAnimation> get blackAttackEffectRight =>
      SpriteAnimation.load(
        "enemy/attack_effect_right.png",
        SpriteAnimationData.sequenced(
          amount: 6,
          stepTime: 0.1,
          textureSize: Vector2(16, 16),
        ),
      );

  static Future<SpriteAnimation> get blackAttackEffectTop =>
      SpriteAnimation.load(
        "enemy/attack_effect_top.png",
        SpriteAnimationData.sequenced(
          amount: 6,
          stepTime: 0.1,
          textureSize: Vector2(16, 16),
        ),
      );

  static Future<SpriteAnimation> get fireBallRight => SpriteAnimation.load(
        "player/fireball_right.png",
        SpriteAnimationData.sequenced(
          amount: 3,
          stepTime: 0.1,
          textureSize: Vector2(23, 23),
        ),
      );

  static Future<SpriteAnimation> get fireBallLeft => SpriteAnimation.load(
        "player/fireball_left.png",
        SpriteAnimationData.sequenced(
          amount: 3,
          stepTime: 0.1,
          textureSize: Vector2(23, 23),
        ),
      );

  static Future<SpriteAnimation> get fireBallBottom => SpriteAnimation.load(
        "player/fireball_bottom.png",
        SpriteAnimationData.sequenced(
          amount: 3,
          stepTime: 0.1,
          textureSize: Vector2(23, 23),
        ),
      );

  static Future<SpriteAnimation> get fireBallTop => SpriteAnimation.load(
        "player/fireball_top.png",
        SpriteAnimationData.sequenced(
          amount: 3,
          stepTime: 0.1,
          textureSize: Vector2(23, 23),
        ),
      );

  static Future<SpriteAnimation> get chestAnimated => SpriteAnimation.load(
        "itens/chest_spritesheet.png",
        SpriteAnimationData.sequenced(
          amount: 8,
          stepTime: 0.1,
          textureSize: Vector2(16, 16),
        ),
      );

  static Future<SpriteAnimation> get torchAnimated => SpriteAnimation.load(
        "itens/torch_spritesheet.png",
        SpriteAnimationData.sequenced(
          amount: 6,
          stepTime: 0.1,
          textureSize: Vector2(16, 16),
        ),
      );

  static Future<Sprite> get barrelSprite => Sprite.load('itens/barrel.png');
  static Future<Sprite> get columnSprite => Sprite.load('itens/column.png');
  static Future<Sprite> get spikesSprite => Sprite.load('itens/spikes.png');
  static Future<Sprite> get potionLifeSprite =>
      Sprite.load('itens/potion_life.png');
}
