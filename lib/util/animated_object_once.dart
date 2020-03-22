import 'dart:ui';

import 'package:bonfire/rpg_game.dart';
import 'package:bonfire/util/animated_object.dart';
import 'package:flame/animation.dart' as FlameAnimation;
import 'package:flame/components/mixins/has_game_ref.dart';

class AnimatedObjectOnce extends AnimatedObject with HasGameRef<RPGGame> {
  Rect position;
  final VoidCallback onFinish;
  final bool onlyUpdate;
  bool _isDestroyed = false;

  AnimatedObjectOnce({
    this.position,
    FlameAnimation.Animation animation,
    this.onFinish,
    this.onlyUpdate = false,
  }) {
    this.animation = animation;
    positionInWorld = position;
  }

  @override
  void render(Canvas canvas) {
    if (onlyUpdate) return;
    super.render(canvas);
  }

  @override
  void update(double dt) {
    if (animation != null && !_isDestroyed) {
      super.update(dt);
      if (animation.isLastFrame) {
        if (onFinish != null) onFinish();
        remove();
      }
    }
  }

  @override
  bool destroy() {
    return _isDestroyed;
  }

  void remove() {
    _isDestroyed = true;
  }
}
