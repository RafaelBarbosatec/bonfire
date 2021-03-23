import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';

class RotationPlayer extends Player {
  final SpriteAnimation animIdle;
  final SpriteAnimation animRun;
  double speed;
  double currentRadAngle;
  bool _move = false;
  SpriteAnimation animation;

  RotationPlayer({
    @required Vector2 position,
    @required this.animIdle,
    @required this.animRun,
    this.speed = 150,
    this.currentRadAngle = -1.55,
    double width = 32,
    double height = 32,
    double life = 100,
  }) : super(
          position: position,
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
    if (animation.getSprite().loaded()) {
      animation.getSprite().render(
            canvas,
            position: position.position,
            size: position.size,
          );
    }
  }
}
