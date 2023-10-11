import 'package:bonfire/bonfire.dart';

/// Enemy used for top-down perspective
class RotationEnemy extends Enemy with UseSpriteAnimation, UseAssetsLoader {
  SpriteAnimation? animIdle;
  SpriteAnimation? animRun;

  RotationEnemy({
    required Vector2 position,
    required Vector2 size,
    required Future<SpriteAnimation> animIdle,
    required Future<SpriteAnimation> animRun,
    double currentRadAngle = -1.55,
    double? speed,
    double life = 100,
    ReceivesAttackFromEnum receivesAttackFrom =
        ReceivesAttackFromEnum.PLAYER_AND_ALLY,
  }) : super(
          position: position,
          size: size,
          life: life,
          speed: speed,
          receivesAttackFrom: receivesAttackFrom,
        ) {
    angle = currentRadAngle;
    loader?.add(AssetToLoad(animIdle, (value) {
      this.animIdle = value;
    }));
    loader?.add(AssetToLoad(animRun, (value) {
      this.animRun = value;
    }));
  }

  @override
  void moveFromAngle(double angle, {double? speed}) {
    setAnimation(animRun);
    this.angle = angle;
    super.moveFromAngle(angle, speed: speed);
  }

  @override
  void idle() {
    setAnimation(animIdle);
    super.idle();
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    idle();
  }

  @override
  void onMount() {
    anchor = Anchor.center;
    super.onMount();
  }
}
