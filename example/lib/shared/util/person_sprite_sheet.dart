import 'package:bonfire/bonfire.dart';

class PersionSpritesheet {
  final String path;

  PersionSpritesheet({this.path = 'human.png'});

  SimpleDirectionAnimation simpleAnimarion() {
    return SimpleDirectionAnimation(
      idleRight: getIdleRight,
      idleDown: getIdleDown,
      idleUp: getIdleUp,
      runRight: getRunRight,
      runDown: getRunDown,
      runUp: getRunUp,
      runDownRight: getRunDownRight,
      runUpRight: getRunUpRight,
      runUpLeft: getRunUpLeft,
      runDownLeft: getRunDownLeft,
    );
  }

  Future<SpriteAnimation> get getIdleDown {
    return SpriteAnimation.load(
      path,
      SpriteAnimationData.sequenced(
        amount: 2,
        stepTime: 0.2,
        textureSize: Vector2.all(32),
      ),
    );
  }

  Future<SpriteAnimation> get getIdleRight {
    return SpriteAnimation.load(
      path,
      SpriteAnimationData.sequenced(
        amount: 2,
        stepTime: 0.2,
        textureSize: Vector2.all(32),
        texturePosition: Vector2(0, 32 * 2),
      ),
    );
  }

  Future<SpriteAnimation> get getIdleUp {
    return SpriteAnimation.load(
      path,
      SpriteAnimationData.sequenced(
        amount: 2,
        stepTime: 0.2,
        textureSize: Vector2.all(32),
        texturePosition: Vector2(0, 32 * 4),
      ),
    );
  }

  get getRunRight {
    return SpriteAnimation.load(
      path,
      SpriteAnimationData.sequenced(
        amount: 2,
        stepTime: 0.2,
        textureSize: Vector2.all(32),
        texturePosition: Vector2(64, 32 * 2),
      ),
    );
  }

  get getRunDown {
    return SpriteAnimation.load(
      path,
      SpriteAnimationData.sequenced(
        amount: 2,
        stepTime: 0.2,
        textureSize: Vector2.all(32),
        texturePosition: Vector2(64, 0),
      ),
    );
  }

  get getRunUp {
    return SpriteAnimation.load(
      path,
      SpriteAnimationData.sequenced(
        amount: 2,
        stepTime: 0.2,
        textureSize: Vector2.all(32),
        texturePosition: Vector2(64, 32 * 4),
      ),
    );
  }

  get getRunDownRight {
    return SpriteAnimation.load(
      path,
      SpriteAnimationData.sequenced(
        amount: 2,
        stepTime: 0.2,
        textureSize: Vector2.all(32),
        texturePosition: Vector2(64, 32 * 1),
      ),
    );
  }

  get getRunUpRight {
    return SpriteAnimation.load(
      path,
      SpriteAnimationData.sequenced(
        amount: 2,
        stepTime: 0.2,
        textureSize: Vector2.all(32),
        texturePosition: Vector2(64, 32 * 3),
      ),
    );
  }

  get getRunUpLeft {
    return SpriteAnimation.load(
      path,
      SpriteAnimationData.sequenced(
        amount: 2,
        stepTime: 0.2,
        textureSize: Vector2.all(32),
        texturePosition: Vector2(64, 32 * 5),
      ),
    );
  }

  get getRunDownLeft {
    return SpriteAnimation.load(
      path,
      SpriteAnimationData.sequenced(
        amount: 2,
        stepTime: 0.2,
        textureSize: Vector2.all(32),
        texturePosition: Vector2(64, 32 * 7),
      ),
    );
  }
}
