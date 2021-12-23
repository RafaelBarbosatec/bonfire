import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/assets_loader.dart';
import 'package:flutter/widgets.dart';

/// Enemy used for top-down perspective
class RotationEnemy extends Enemy {
  SpriteAnimation? animIdle;
  SpriteAnimation? animRun;

  SpriteAnimation? animation;

  double currentRadAngle;

  final _loader = AssetsLoader();

  RotationEnemy({
    required Vector2 position,
    required Future<SpriteAnimation> animIdle,
    required Future<SpriteAnimation> animRun,
    double height = 32,
    double width = 32,
    this.currentRadAngle = -1.55,
    double speed = 100,
    double life = 100,
  }) : super(
          position: position,
          height: height,
          width: width,
          life: life,
          speed: speed,
        ) {
    _loader.add(AssetToLoad(animIdle, (value) {
      this.animIdle = value;
    }));
    _loader.add(AssetToLoad(animRun, (value) {
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
    currentRadAngle = angle;
    super.moveFromAngleDodgeObstacles(speed, angle, onCollision: onCollision);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.save();
    canvas.translate(position.center.dx, position.center.dy);
    canvas.rotate(currentRadAngle == 0.0 ? 0.0 : currentRadAngle + (pi / 2));
    canvas.translate(-position.center.dx, -position.center.dy);
    _renderAnimation(canvas);
    canvas.restore();
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
    animation?.getSprite().renderFromVector2Rect(
          canvas,
          this.position,
          opacity: opacity,
        );
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await _loader.load();
    idle();
  }
}
