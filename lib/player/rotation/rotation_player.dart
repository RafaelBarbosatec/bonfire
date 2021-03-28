import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:flame/animation.dart' as FlameAnimation;
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';

class RotationPlayer extends Player {
  final FlameAnimation.Animation animIdle;
  final FlameAnimation.Animation animRun;
  double speed;
  double currentRadAngle;
  bool _move = false;
  FlameAnimation.Animation animation;

  RotationPlayer({
    @required Position initPosition,
    @required this.animIdle,
    @required this.animRun,
    this.speed = 150,
    this.currentRadAngle = -1.55,
    double width = 32,
    double height = 32,
    double life = 100,
  }) : super(
          initPosition: initPosition,
          width: width,
          height: height,
          life: life,
        ) {
    this.animation = animIdle;
  }

  @override
  void joystickChangeDirectional(JoystickDirectionalEvent event) {
    if (event.directional != JoystickMoveDirectional.IDLE &&
        !isDead &&
        event.radAngle != 0.0) {
      currentRadAngle = event.radAngle;
      _move = true;
      this.animation = animRun;
    } else {
      _move = false;
      this.animation = animIdle;
    }
    super.joystickChangeDirectional(event);
  }

  @override
  void update(double dt) {
    if (_move && !isDead) {
      moveFromAngle(speed, currentRadAngle);
    }
    animation?.update(dt);
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    canvas.save();
    canvas.translate(position.center.dx, position.center.dy);
    canvas.rotate(currentRadAngle == 0.0 ? 0.0 : currentRadAngle + (pi / 2));
    canvas.translate(-position.center.dx, -position.center.dy);
    _renderAnimation(canvas);
    canvas.restore();
  }

  void _renderAnimation(Canvas canvas) {
    if (animation == null || position == null) return;
    if (animation.loaded()) {
      animation.getSprite().renderRect(canvas, position);
    }
  }
}
