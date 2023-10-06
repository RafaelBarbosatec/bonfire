import 'package:bonfire/bonfire.dart';

class HumanTopdownPlayerSpritesheet {
  static Future<SpriteAnimation> idle() {
    return SpriteAnimation.load(
      'topdown/idle.png',
      SpriteAnimationData.sequenced(
        amount: 5,
        stepTime: 0.1,
        textureSize: Vector2(24, 16),
      ),
    );
  }

  static Future<SpriteAnimation> run() {
    return SpriteAnimation.load(
      'topdown/running.png',
      SpriteAnimationData.sequenced(
        amount: 5,
        stepTime: 0.1,
        textureSize: Vector2(24, 16),
      ),
    );
  }
}
