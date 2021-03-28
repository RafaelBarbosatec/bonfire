import 'dart:math';

import 'package:bonfire/enemy/enemy.dart';
import 'package:flame/animation.dart' as FlameAnimation;
import 'package:flame/position.dart';
import 'package:flutter/widgets.dart';

class RotationEnemy extends Enemy {
  final FlameAnimation.Animation animIdle;
  final FlameAnimation.Animation animRun;

  FlameAnimation.Animation animation;

  /// Variable that represents the speed of the enemy.
  final double speed;
  double currentRadAngle;

  RotationEnemy({
    @required Position initPosition,
    @required this.animIdle,
    @required this.animRun,
    double height = 32,
    double width = 32,
    this.currentRadAngle = -1.55,
    this.speed = 100,
    double life = 100,
  }) : super(
          initPosition: initPosition,
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
      canvas.translate(position.center.dx, position.center.dy);
      canvas.rotate(currentRadAngle == 0.0 ? 0.0 : currentRadAngle + (pi / 2));
      canvas.translate(-position.center.dx, -position.center.dy);
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
    if (animation.loaded()) {
      animation.getSprite().renderRect(canvas, position);
    }
  }
}
