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

  // @override
  // void moveFromAngle(double angle, {double? speed}) {
  //   setAnimation(animRun);
  //   this.angle = angle;
  //   super.moveFromAngle(angle, speed: speed);
  // }

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
