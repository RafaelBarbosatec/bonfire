import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/assets_loader.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';

class RotationPlayer extends Player with WithAssetsLoader {
  SpriteAnimation? animIdle;
  SpriteAnimation? animRun;
  SpriteAnimation? animation;

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
      this.animation = animRun;
    } else {
      this.animation = animIdle;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    angle = movementRadAngle;
    animation?.update(dt);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    _renderAnimation(canvas);
  }

  void _renderAnimation(Canvas canvas) {
    if (animation == null) return;
    animation?.getSprite().renderWithOpacity(
          canvas,
          position,
          size,
          opacity: opacity,
        );
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    this.animation = this.animIdle;
  }
}
