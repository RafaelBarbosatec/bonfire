import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/enemy/enemy.dart';
import 'package:bonfire/util/assets_loader.dart';
import 'package:flame/components.dart';
import 'package:flutter/widgets.dart';

class RotationEnemy extends Enemy {
  SpriteAnimation animIdle;
  SpriteAnimation animRun;

  SpriteAnimation animation;

  /// Variable that represents the speed of the enemy.
  final double speed;
  double currentRadAngle;

  final _loader = AssetsLoader();

  RotationEnemy({
    @required Vector2 position,
    @required Future<SpriteAnimation> animIdle,
    @required Future<SpriteAnimation> animRun,
    double height = 32,
    double width = 32,
    this.currentRadAngle = -1.55,
    this.speed = 100,
    double life = 100,
  }) : super(
          position: position,
          height: height,
          width: width,
          life: life,
        ) {
    _loader.add(AssetToLoad(animIdle, (value) {
      this.animIdle = value;
    }));
    _loader.add(AssetToLoad(animRun, (value) {
      this.animRun = value;
    }));
  }

  @override
  void moveFromAngleDodgeObstacles(double speed, double angle,
      {Function notMove}) {
    this.animation = animRun;
    currentRadAngle = angle;
    super.moveFromAngleDodgeObstacles(speed, angle, notMove: notMove);
  }

  @override
  void render(Canvas canvas) {
    if (this.isVisibleInCamera()) {
      canvas.save();
      canvas.translate(position.rect.center.dx, position.rect.center.dy);
      canvas.rotate(currentRadAngle == 0.0 ? 0.0 : currentRadAngle + (pi / 2));
      canvas.translate(-position.rect.center.dx, -position.rect.center.dy);
      _renderAnimation(canvas);
      canvas.restore();
    }
  }

  @override
  void update(double dt) {
    if (isVisibleInCamera()) {
      animation?.update(dt);
    }
    super.update(dt);
  }

  void idle() {
    this.animation = animIdle;
  }

  void _renderAnimation(Canvas canvas) {
    if (position == null) return;
    if (animation?.getSprite()?.loaded() == true) {
      animation.getSprite().renderFromVector2Rect(
            canvas,
            this.position,
          );
    }
  }

  @override
  Future<void> onLoad() async {
    await _loader.load();
    idle();
  }
}
