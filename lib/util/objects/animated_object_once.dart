import 'dart:math';
import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/lighting/lighting_config.dart';
import 'package:bonfire/util/objects/animated_object.dart';
import 'package:flame/animation.dart' as FlameAnimation;

class AnimatedObjectOnce extends AnimatedObject with Lighting {
  final VoidCallback onFinish;
  final VoidCallback onStartAnimation;
  final bool onlyUpdate;
  final double rotateRadAngle;
  bool _notifyStart = false;
  final LightingConfig lightingConfig;

  AnimatedObjectOnce({
    Rect position,
    FlameAnimation.Animation animation,
    this.onFinish,
    this.onStartAnimation,
    this.onlyUpdate = false,
    this.rotateRadAngle,
    this.lightingConfig,
  }) {
    this.animation = animation;
    this.position = position;
  }

  @override
  void render(Canvas canvas) {
    if (onlyUpdate || this.position == null) return;
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
