import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/animated_object.dart';
import 'package:bonfire/util/animated_object_once.dart';
import 'package:flame/animation.dart' as FlameAnimation;

class AnimatedFollowerObject extends AnimatedObjectOnce {
  final AnimatedObject target;
  final Position positionFromTarget;
  final double height;
  final double width;
  final bool loopAnimation;
  AnimatedFollowerObject(
      {FlameAnimation.Animation animation,
      this.target,
      this.positionFromTarget,
      this.height = 16,
      this.width = 16,
      this.loopAnimation = false})
      : super(animation: animation);

  @override
  void update(double dt) {
    Position newPosition = positionFromTarget ?? Position.empty();
    this.positionInWorld = Rect.fromLTWH(
      target.positionInWorld.left,
      target.positionInWorld.top,
      width,
      height,
    ).translate(newPosition.x, newPosition.y);

    if (loopAnimation) {
      if (this.animation != null) this.animation.update(dt);
      this.position = Rect.fromLTWH(
        this.positionInWorld.left + gameRef.mapCamera.x,
        this.positionInWorld.top + gameRef.mapCamera.y,
        this.positionInWorld.width,
        this.positionInWorld.height,
      );
    } else {
      super.update(dt);
    }
  }
}
