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
/// on 24/03/22

/// Enemy used for top-down perspective
class RotationAlly extends Ally with UseSpriteAnimation, UseAssetsLoader {
  SpriteAnimation? animIdle;
  SpriteAnimation? animRun;

  RotationAlly({
    required Vector2 position,
    required Vector2 size,
    required Future<SpriteAnimation> animIdle,
    required Future<SpriteAnimation> animRun,
    double currentRadAngle = -1.55,
    double speed = 100,
    double life = 100,
    ReceivesAttackFromEnum receivesAttackFrom = ReceivesAttackFromEnum.ENEMY,
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
}
