import 'package:bonfire/bonfire.dart';

class RotationPlayer extends Player with UseSpriteAnimation, UseAssetsLoader {
  SpriteAnimation? animIdle;
  SpriteAnimation? animRun;

  bool _isRunning = false;

  RotationPlayer({
    required super.position,
    required super.size,
    required Future<SpriteAnimation> animIdle,
    required Future<SpriteAnimation> animRun,
    super.speed,
    double currentRadAngle = -1.55,
    super.life,
  }) {
    setupMovementByJoystick(
      moveType: MovementByJoystickType.angle,
    );
    movementByJoystickRadAngle = currentRadAngle;
    loader?.add(
      AssetToLoad<SpriteAnimation>(
        animIdle,
        (value) => this.animIdle = value,
      ),
    );
    loader?.add(
      AssetToLoad<SpriteAnimation>(
        animRun,
        (value) => this.animRun = value,
      ),
    );
  }

  @override
  void onJoystickChangeDirectional(JoystickDirectionalEvent event) {
    super.onJoystickChangeDirectional(event);
    if (event.directional == JoystickMoveDirectional.IDLE) {
      _isRunning = false;
      setAnimation(animIdle);
    } else if (!isDead && !_isRunning) {
      _isRunning = true;
      setAnimation(animRun);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    angle = movementByJoystickRadAngle;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    setAnimation(animIdle);
  }

  @override
  void onMount() {
    anchor = Anchor.center;
    super.onMount();
  }
}
