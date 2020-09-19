import 'dart:math';
import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/lighting/lighting.dart';
import 'package:bonfire/lighting/lighting_config.dart';
import 'package:bonfire/objects/animated_object.dart';
import 'package:flame/animation.dart' as FlameAnimation;

class AnimatedObjectOnce extends AnimatedObject with Lighting {
  final VoidCallback onFinish;
  final VoidCallback onStartAnimation;
  final double rotateRadAngle;
  bool _notifyStart = false;
  bool _destroy = false;
  final LightingConfig lightingConfig;

  AnimatedObjectOnce({
    Rect position,
    FlameAnimation.Animation animation,
    this.onFinish,
    this.onStartAnimation,
    this.rotateRadAngle,
    this.lightingConfig,
  }) {
    this.animation = animation;
    this.position = position;
  }

  @override
  void render(Canvas canvas) {
    if (this.position == null) return;
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
    if (_destroy) {
      if (onFinish != null) onFinish();
      remove();
    }
    super.update(dt);
    if (animation != null && !destroy()) {
      if (animation.currentIndex == 1 && !_notifyStart) {
        _notifyStart = true;
        if (onStartAnimation != null) onStartAnimation();
      }
      if (animation.isLastFrame) {
        _destroy = true;
      }
    }
  }
}
