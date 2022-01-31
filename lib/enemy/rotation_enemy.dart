import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/assets_loader.dart';
import 'package:flutter/widgets.dart';

/// Enemy used for top-down perspective
class RotationEnemy extends Enemy {
  SpriteAnimation? animIdle;
  SpriteAnimation? animRun;

  SpriteAnimation? animation;

  AssetsLoader? _loader = AssetsLoader();

  RotationEnemy({
    required Vector2 position,
    required Vector2 size,
    required Future<SpriteAnimation> animIdle,
    required Future<SpriteAnimation> animRun,
    double currentRadAngle = -1.55,
    double speed = 100,
    double life = 100,
  }) : super(
          position: position,
          size: size,
          life: life,
          speed: speed,
        ) {
    angle = currentRadAngle;
    _loader?.add(AssetToLoad(animIdle, (value) {
      this.animIdle = value;
    }));
    _loader?.add(AssetToLoad(animRun, (value) {
      this.animRun = value;
    }));
  }

  @override
  void moveFromAngleDodgeObstacles(
    double speed,
    double angle, {
    VoidCallback? onCollision,
  }) {
    this.animation = animRun;
    this.angle = angle;
    super.moveFromAngleDodgeObstacles(speed, angle, onCollision: onCollision);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    _renderAnimation(canvas);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (this.isVisible) {
      animation?.update(dt);
    }
  }

  void idle() {
    this.animation = animIdle;
    super.idle();
  }

  void _renderAnimation(Canvas canvas) {
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
    await _loader?.load();
    _loader = null;
    idle();
  }
}
