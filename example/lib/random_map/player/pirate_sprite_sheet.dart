import 'package:bonfire/bonfire.dart';

///
/// Created by
///
/// ─▄▀─▄▀
/// ──▀──▀
/// █▀▀▀▀▀█▄
/// █░░░░░█─█
/// ▀▄▄▄▄▄▀▀
///
/// Rafaelbarbosatec
/// on 03/06/22

class PirateSpriteSheet {
  static SimpleDirectionAnimation getAnimation() {
    return SimpleDirectionAnimation(
      runRight: SpriteAnimation.load(
        'player/pirate.png',
        SpriteAnimationData.sequenced(
          amount: 4,
          stepTime: 0.1,
          textureSize: Vector2.all(32),
          texturePosition: Vector2(0, 7 * 32),
        ),
      ),
      idleRight: SpriteAnimation.load(
        'player/pirate.png',
        SpriteAnimationData.sequenced(
          amount: 4,
          stepTime: 0.1,
          textureSize: Vector2.all(32),
          texturePosition: Vector2(0, 3 * 32),
        ),
      ),
      runUp: SpriteAnimation.load(
        'player/pirate.png',
        SpriteAnimationData.sequenced(
          amount: 4,
          stepTime: 0.1,
          textureSize: Vector2.all(32),
          texturePosition: Vector2(0, 4 * 32),
        ),
      ),
      runDown: SpriteAnimation.load(
        'player/pirate.png',
        SpriteAnimationData.sequenced(
          amount: 4,
          stepTime: 0.1,
          textureSize: Vector2.all(32),
          texturePosition: Vector2(0, 5 * 32),
        ),
      ),
      idleUp: SpriteAnimation.load(
        'player/pirate.png',
        SpriteAnimationData.sequenced(
          amount: 4,
          stepTime: 0.1,
          textureSize: Vector2.all(32),
        ),
      ),
      idleDown: SpriteAnimation.load(
        'player/pirate.png',
        SpriteAnimationData.sequenced(
          amount: 4,
          stepTime: 0.1,
          textureSize: Vector2.all(32),
          texturePosition: Vector2(0, 32),
        ),
      ),
    );
  }
}
