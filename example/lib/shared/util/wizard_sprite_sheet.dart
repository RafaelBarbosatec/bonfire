import 'package:bonfire/bonfire.dart';

class WizardSpriteSheet {
  static Future<SpriteAnimation> get idle => SpriteAnimation.load(
        "npc/wizard_idle.png",
        SpriteAnimationData.sequenced(
          amount: 2,
          stepTime: 1,
          textureSize: Vector2(16, 20),
        ),
      );

  static SimpleDirectionAnimation get simpleDirectionAnimation =>
      SimpleDirectionAnimation(
        idleRight: idle,
        runRight: idle,
      );
}
