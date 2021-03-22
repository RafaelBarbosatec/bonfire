import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/enemy/enemy.dart';
import 'package:flutter/widgets.dart';

class RotationEnemy extends Enemy {
  final SpriteAnimation animIdle;
  final SpriteAnimation animRun;

  SpriteAnimation animation;

  /// Variable that represents the speed of the enemy.
  final double speed;
  double currentRadAngle;

  RotationEnemy({
    @required Offset position,
    @required this.animIdle,
    @required this.animRun,
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
    idle();
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
    if (animation == null || position == null) return;
    animation.getSprite().render(
          canvas,
          position: position.position,
          size: position.size,
        );
  }
}
