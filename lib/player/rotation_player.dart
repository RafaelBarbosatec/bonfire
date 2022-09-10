import 'package:bonfire/bonfire.dart';

class RotationPlayer extends Player with UseSpriteAnimation, UseAssetsLoader {
  SpriteAnimation? animIdle;
  SpriteAnimation? animRun;

  RotationPlayer({
    required Vector2 position,
    required Vector2 size,
    required Future<SpriteAnimation> animIdle,
    required Future<SpriteAnimation> animRun,
    double speed = 150,
    double currentRadAngle = -1.55,
    double life = 100,
  }) : super(
          position: position,
          size: size,
          life: life,
          speed: speed,
        ) {
    // for full 360 degree movement
    dPadAngles = false;
    // for the default 8 way movement
    // dPadAngles = true;
    movementRadAngle = currentRadAngle;
    loader?.add(AssetToLoad(animIdle, (value) => this.animIdle = value));
    loader?.add(AssetToLoad(animRun, (value) => this.animRun = value));
  }

  @override
  void joystickChangeDirectional(JoystickDirectionalEvent event) {
    super.joystickChangeDirectional(event);
    if (event.directional != JoystickMoveDirectional.IDLE && !isDead) {
      animation = animRun;
    } else {
      animation = animIdle;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    angle = movementRadAngle;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    animation = animIdle;
  }
}
