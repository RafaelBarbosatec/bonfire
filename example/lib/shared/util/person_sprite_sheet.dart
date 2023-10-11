import 'package:bonfire/bonfire.dart';

enum PersonAttackEnum {
  meeleDown,
  meeleUp,
  meeleLeft,
  meeleRight,
  meeleUpRight,
  meeleDownRight,
  meeleUpLeft,
  meeleDownLeft,

  rangeDown,
  rangeUp,
  rangeLeft,
  rangeRight,
  rangeUpRight,
  rangeDownRight,
  rangeUpLeft,
  rangeDownLeft,
}

class PersonSpritesheet {
  final String path;

  PersonSpritesheet({this.path = 'human.png'});

  SimpleDirectionAnimation simpleAnimation() {
    return SimpleDirectionAnimation(
      idleRight: getIdleRight,
      idleDown: getIdleDown,
      idleUp: getIdleUp,
      idleDownRight: getIdleDownRight,
      idleDownLeft: getIdleDownLeft,
      idleUpLeft: getIdleUpLeft,
      idleUpRight: getIdleUpRight,
      runRight: getRunRight,
      runDown: getRunDown,
      runUp: getRunUp,
      runDownRight: getRunDownRight,
      runUpRight: getRunUpRight,
      runUpLeft: getRunUpLeft,
      runDownLeft: getRunDownLeft,
      others: {
        PersonAttackEnum.meeleDown: getAttackMeleeDown,
        PersonAttackEnum.meeleUp: getAttackMeleeUp,
        PersonAttackEnum.meeleLeft: getAttackMeleeLeft,
        PersonAttackEnum.meeleRight: getAttackMeleeRight,
        PersonAttackEnum.meeleUpRight: getAttackMeleeUpRight,
        PersonAttackEnum.meeleUpLeft: getAttackMeleeUpLeft,
        PersonAttackEnum.meeleDownRight: getAttackMeleeDownRight,
        PersonAttackEnum.meeleDownLeft: getAttackMeleeDownLeft,
        PersonAttackEnum.rangeDown: getAttackRangeDown,
        PersonAttackEnum.rangeUp: getAttackRangeUp,
        PersonAttackEnum.rangeLeft: getAttackRangeLeft,
        PersonAttackEnum.rangeRight: getAttackRangeRight,
        PersonAttackEnum.rangeUpRight: getAttackRangeUpRight,
        PersonAttackEnum.rangeUpLeft: getAttackRangeUpLeft,
        PersonAttackEnum.rangeDownRight: getAttackRangeDownRight,
        PersonAttackEnum.rangeDownLeft: getAttackRangeDownLeft,
      },
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

  Future<SpriteAnimation> get getIdleDownRight {
    return SpriteAnimation.load(
      path,
      SpriteAnimationData.sequenced(
        amount: 2,
        stepTime: 0.2,
        textureSize: Vector2.all(32),
        texturePosition: Vector2(0, 32 * 1),
      ),
    );
  }

  Future<SpriteAnimation> get getIdleUpRight {
    return SpriteAnimation.load(
      path,
      SpriteAnimationData.sequenced(
        amount: 2,
        stepTime: 0.2,
        textureSize: Vector2.all(32),
        texturePosition: Vector2(0, 32 * 3),
      ),
    );
  }

  Future<SpriteAnimation> get getIdleUpLeft {
    return SpriteAnimation.load(
      path,
      SpriteAnimationData.sequenced(
        amount: 2,
        stepTime: 0.2,
        textureSize: Vector2.all(32),
        texturePosition: Vector2(0, 32 * 5),
      ),
    );
  }

  Future<SpriteAnimation> get getIdleDownLeft {
    return SpriteAnimation.load(
      path,
      SpriteAnimationData.sequenced(
        amount: 2,
        stepTime: 0.2,
        textureSize: Vector2.all(32),
        texturePosition: Vector2(0, 32 * 7),
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

  Future<SpriteAnimation> get getAttackMeleeDown {
    return SpriteAnimation.load(
      path,
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.2,
        textureSize: Vector2.all(32),
        texturePosition: Vector2(32 * 5, 0),
      ),
    );
  }

  Future<SpriteAnimation> get getAttackMeleeUp {
    return SpriteAnimation.load(
      path,
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.2,
        textureSize: Vector2.all(32),
        texturePosition: Vector2(32 * 5, 32 * 4),
      ),
    );
  }

  Future<SpriteAnimation> get getAttackMeleeLeft {
    return SpriteAnimation.load(
      path,
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.2,
        textureSize: Vector2.all(32),
        texturePosition: Vector2(32 * 5, 32 * 6),
      ),
    );
  }

  Future<SpriteAnimation> get getAttackMeleeRight {
    return SpriteAnimation.load(
      path,
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.2,
        textureSize: Vector2.all(32),
        texturePosition: Vector2(32 * 5, 32 * 2),
      ),
    );
  }

  Future<SpriteAnimation> get getAttackMeleeDownRight {
    return SpriteAnimation.load(
      path,
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.2,
        textureSize: Vector2.all(32),
        texturePosition: Vector2(32 * 5, 32),
      ),
    );
  }

  Future<SpriteAnimation> get getAttackMeleeUpRight {
    return SpriteAnimation.load(
      path,
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.2,
        textureSize: Vector2.all(32),
        texturePosition: Vector2(32 * 5, 32 * 3),
      ),
    );
  }

  Future<SpriteAnimation> get getAttackMeleeUpLeft {
    return SpriteAnimation.load(
      path,
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.2,
        textureSize: Vector2.all(32),
        texturePosition: Vector2(32 * 5, 32 * 5),
      ),
    );
  }

  Future<SpriteAnimation> get getAttackMeleeDownLeft {
    return SpriteAnimation.load(
      path,
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.2,
        textureSize: Vector2.all(32),
        texturePosition: Vector2(32 * 5, 32 * 7),
      ),
    );
  }

  Future<SpriteAnimation> get getAttackRangeDown {
    return SpriteAnimation.load(
      path,
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.2,
        textureSize: Vector2.all(32),
        texturePosition: Vector2(32 * 9, 0),
      ),
    );
  }

  Future<SpriteAnimation> get getAttackRangeUp {
    return SpriteAnimation.load(
      path,
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.2,
        textureSize: Vector2.all(32),
        texturePosition: Vector2(32 * 9, 32 * 4),
      ),
    );
  }

  Future<SpriteAnimation> get getAttackRangeLeft {
    return SpriteAnimation.load(
      path,
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.2,
        textureSize: Vector2.all(32),
        texturePosition: Vector2(32 * 9, 32 * 6),
      ),
    );
  }

  Future<SpriteAnimation> get getAttackRangeRight {
    return SpriteAnimation.load(
      path,
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.2,
        textureSize: Vector2.all(32),
        texturePosition: Vector2(32 * 9, 32 * 2),
      ),
    );
  }

  Future<SpriteAnimation> get getAttackRangeDownRight {
    return SpriteAnimation.load(
      path,
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.2,
        textureSize: Vector2.all(32),
        texturePosition: Vector2(32 * 9, 32),
      ),
    );
  }

  Future<SpriteAnimation> get getAttackRangeUpRight {
    return SpriteAnimation.load(
      path,
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.2,
        textureSize: Vector2.all(32),
        texturePosition: Vector2(32 * 9, 32 * 3),
      ),
    );
  }

  Future<SpriteAnimation> get getAttackRangeUpLeft {
    return SpriteAnimation.load(
      path,
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.2,
        textureSize: Vector2.all(32),
        texturePosition: Vector2(32 * 9, 32 * 5),
      ),
    );
  }

  Future<SpriteAnimation> get getAttackRangeDownLeft {
    return SpriteAnimation.load(
      path,
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.2,
        textureSize: Vector2.all(32),
        texturePosition: Vector2(32 * 9, 32 * 7),
      ),
    );
  }
}
