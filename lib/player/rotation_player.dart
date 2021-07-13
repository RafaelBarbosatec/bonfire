import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/assets_loader.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';

class RotationPlayer extends Player {
  SpriteAnimation? animIdle;
  SpriteAnimation? animRun;
  double? currentRadAngle;
  bool _move = false;
  SpriteAnimation? animation;
  final _loader = AssetsLoader();

  RotationPlayer({
    required Vector2 position,
    required Future<SpriteAnimation> animIdle,
    required Future<SpriteAnimation> animRun,
    double speed = 150,
    this.currentRadAngle = -1.55,
    double width = 32,
    double height = 32,
    double life = 100,
  }) : super(
          position: position,
          width: width,
          height: height,
          life: life,
          speed: speed,
        ) {
    _loader.add(AssetToLoad(animIdle, (value) => this.animIdle = value));
    _loader.add(AssetToLoad(animRun, (value) => this.animRun = value));
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
    if (_move && !isDead && currentRadAngle != null) {
      moveFromAngle(speed, currentRadAngle!);
    }
    animation?.update(dt);
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    if (currentRadAngle == null) return;
    canvas.save();
    canvas.translate(position.center.dx, position.center.dy);
    canvas.rotate(currentRadAngle == 0.0 ? 0.0 : currentRadAngle! + (pi / 2));
    canvas.translate(-position.center.dx, -position.center.dy);
    _renderAnimation(canvas);
    canvas.restore();
  }

  void _renderAnimation(Canvas canvas) {
    if (animation == null) return;
    animation?.getSprite().renderFromVector2Rect(canvas, position);
  }

  @override
  Future<void> onLoad() async {
    await _loader.load();
    this.animation = this.animIdle;
  }
}
