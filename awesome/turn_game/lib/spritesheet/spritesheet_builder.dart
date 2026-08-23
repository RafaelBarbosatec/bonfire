// ignore_for_file: constant_identifier_names

import 'package:bonfire/bonfire.dart';

class SpriteSheetBuilder {
  static const SPRITE_HERO = 'hero.png';
  static const SPRITE_GHOST = 'ghost.png';
  static const SPRITE_KNIGHT = 'knight.png';
  static const SPRITE_NECROMANCER = 'necromancer.png';

  static const ANIMATION_HITED_RIGHT = 'ANIMATION_HITED_RIGHT';
  static const ANIMATION_HITED_LEFT = 'ANIMATION_HITED_LEFT';
  static const ANIMATION_DIE_RIGHT = 'ANIMATION_DIE_RIGHT';
  static const ANIMATION_DIE_LEFT = 'ANIMATION_DIE_LEFT';

  static SimpleDirectionAnimation build(String path) {
    return SimpleDirectionAnimation(
      idleRight: SpriteAnimation.load(
        path,
        SpriteAnimationData.sequenced(
          amount: 4,
          stepTime: 0.15,
          textureSize: Vector2(24, 24),
          texturePosition: Vector2(0, 0),
        ),
      ),
      runRight: SpriteAnimation.load(
        path,
        SpriteAnimationData.sequenced(
          amount: 4,
          stepTime: 0.15,
          textureSize: Vector2(24, 24),
          texturePosition: Vector2(0, 48),
        ),
      ),
      others: {
        ANIMATION_HITED_RIGHT: SpriteAnimation.load(
          path,
          SpriteAnimationData.sequenced(
            amount: 4,
            stepTime: 0.15,
            textureSize: Vector2(24, 24),
            texturePosition: Vector2(0, 96),
          ),
        ),
        ANIMATION_HITED_LEFT: SpriteAnimation.load(
          path,
          SpriteAnimationData.sequenced(
            amount: 4,
            stepTime: 0.15,
            textureSize: Vector2(24, 24),
            texturePosition: Vector2(96, 96),
          ),
        ),
        ANIMATION_DIE_RIGHT: SpriteAnimation.load(
          path,
          SpriteAnimationData.sequenced(
            amount: 4,
            stepTime: 0.15,
            textureSize: Vector2(24, 24),
            texturePosition: Vector2(0, 120),
          ),
        ),
        ANIMATION_DIE_LEFT: SpriteAnimation.load(
          path,
          SpriteAnimationData.sequenced(
            amount: 4,
            stepTime: 0.15,
            textureSize: Vector2(24, 24),
            texturePosition: Vector2(96, 120),
          ),
        ),
      },
    );
  }

  static Future<SpriteAnimation> get attackRight => SpriteAnimation.load(
        'attack_effect_right.png',
        SpriteAnimationData.sequenced(
          amount: 3,
          stepTime: 0.1,
          textureSize: Vector2(16, 16),
        ),
      );

      static Future<SpriteAnimation> get fireballRight => SpriteAnimation.load(
        'fireball_right.png',
        SpriteAnimationData.sequenced(
          amount: 3,
          stepTime: 0.1,
          textureSize: Vector2(23, 23),
        ),
      );
}
