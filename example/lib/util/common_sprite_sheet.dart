import 'package:bonfire/bonfire.dart';

class CommonSpriteSheet {
  static Animation get explosionAnimation => Animation.sequenced(
        'player/explosion_fire.png',
        6,
        textureWidth: 32,
        textureHeight: 32,
      );

  static Animation get emote => Animation.sequenced(
        'player/emote_exclamacao.png',
        8,
        textureWidth: 32,
        textureHeight: 32,
      );
  static Animation get smokeExplosion => Animation.sequenced(
        "smoke_explosin.png",
        6,
        textureWidth: 16,
        textureHeight: 16,
      );

  static Animation get whiteAttackEffectBottom => Animation.sequenced(
        'player/atack_effect_bottom.png',
        6,
        textureWidth: 16,
        textureHeight: 16,
      );

  static Animation get whiteAttackEffectLeft => Animation.sequenced(
        'player/atack_effect_left.png',
        6,
        textureWidth: 16,
        textureHeight: 16,
      );

  static Animation get whiteAttackEffectRight => Animation.sequenced(
        'player/atack_effect_right.png',
        6,
        textureWidth: 16,
        textureHeight: 16,
      );

  static Animation get whiteAttackEffectTop => Animation.sequenced(
        'player/atack_effect_top.png',
        6,
        textureWidth: 16,
        textureHeight: 16,
      );

  static Animation get blackAttackEffectBottom => Animation.sequenced(
        'enemy/atack_effect_bottom.png',
        6,
        textureWidth: 16,
        textureHeight: 16,
      );

  static Animation get blackAttackEffectLeft => Animation.sequenced(
        'enemy/atack_effect_left.png',
        6,
        textureWidth: 16,
        textureHeight: 16,
      );

  static Animation get blackAttackEffectRight => Animation.sequenced(
        'enemy/atack_effect_right.png',
        6,
        textureWidth: 16,
        textureHeight: 16,
      );

  static Animation get blackAttackEffectTop => Animation.sequenced(
        'enemy/atack_effect_top.png',
        6,
        textureWidth: 16,
        textureHeight: 16,
      );

  static Animation get fireBallRight => Animation.sequenced(
        'player/fireball_right.png',
        3,
        textureWidth: 23,
        textureHeight: 23,
      );

  static Animation get fireBallLeft => Animation.sequenced(
        'player/fireball_left.png',
        3,
        textureWidth: 23,
        textureHeight: 23,
      );

  static Animation get fireBallBottom => Animation.sequenced(
        'player/fireball_bottom.png',
        3,
        textureWidth: 23,
        textureHeight: 23,
      );

  static Animation get fireBallTop => Animation.sequenced(
        'player/fireball_top.png',
        3,
        textureWidth: 23,
        textureHeight: 23,
      );
}
