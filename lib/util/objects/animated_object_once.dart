import 'dart:math';
import 'dart:ui';

import 'package:bonfire/util/objects/animated_object.dart';
import 'package:flame/animation.dart' as FlameAnimation;

class AnimatedObjectOnce extends AnimatedObject {
  Rect position;
  final VoidCallback onFinish;
  final VoidCallback onStartAnimation;
  final bool onlyUpdate;
  final double rotateRadAngle;
  bool _notifyStart = false;

  AnimatedObjectOnce({
    this.position,
    FlameAnimation.Animation animation,
    this.onFinish,
    this.onStartAnimation,
    this.onlyUpdate = false,
    this.rotateRadAngle,
  }) {
    this.animation = animation;
    positionInWorld = position;
  }

  @override
  void render(Canvas canvas) {
    if (onlyUpdate) return;
    if (rotateRadAngle != null) {
      canvas.save();
      canvas.translate(position.center.dx, position.center.dy);
      canvas.rotate(rotateRadAngle == 0.0 ? 0.0 : rotateRadAngle + (pi / 2));
      canvas.translate(-position.center.dx, -position.center.dy);
      super.render(canvas);
      canvas.restore();
    } else {
      super.render(canvas);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (animation != null && !destroy()) {
      if (animation.currentIndex == 1 && !_notifyStart) {
        _notifyStart = true;
        if (onStartAnimation != null) onStartAnimation();
      }
      if (animation.isLastFrame) {
        if (onFinish != null) onFinish();
        remove();
      }
    }
  }
}
