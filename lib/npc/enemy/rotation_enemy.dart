import 'package:bonfire/bonfire.dart';

/// Enemy used for top-down perspective
class RotationEnemy extends Enemy with UseSpriteAnimation, UseAssetsLoader {
  SpriteAnimation? animIdle;
  SpriteAnimation? animRun;

  RotationEnemy({
    required super.position,
    required super.size,
    required Future<SpriteAnimation> animIdle,
    required Future<SpriteAnimation> animRun,
    double currentRadAngle = -1.55,
    super.speed,
    super.life = 100,
    super.receivesAttackFrom,
  }) {
    angle = currentRadAngle;
    loader?.add(
      AssetToLoad<SpriteAnimation>(animIdle, (value) {
        this.animIdle = value;
      }),
    );
    loader?.add(
      AssetToLoad<SpriteAnimation>(animRun, (value) {
        this.animRun = value;
      }),
    );
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
