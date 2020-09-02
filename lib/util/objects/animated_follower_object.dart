import 'dart:ui';

import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/objects/animated_object.dart';
import 'package:flame/animation.dart' as FlameAnimation;

class AnimatedFollowerObject extends AnimatedObject {
  final GameComponent target;
  final Position positionFromTarget;
  final double height;
  final double width;
  final bool loopAnimation;
  AnimatedFollowerObject({
    FlameAnimation.Animation animation,
    this.target,
    this.positionFromTarget,
    this.height = 16,
    this.width = 16,
    this.loopAnimation = false,
  }) {
    this.animation = animation;
  }

  @override
  void update(double dt) {
    super.update(dt);
    Position newPosition = positionFromTarget ?? Position.empty();
    this.position = Rect.fromLTWH(
      target.position.left,
      target.position.top,
      width,
      height,
    ).translate(newPosition.x, newPosition.y);

    if (!loopAnimation) {
      if (animation.isLastFrame) {
        remove();
      }
    }
  }
}
