import 'dart:ui';

import 'package:flame/animation.dart' as FlameAnimation;

class ControlledUpdateAnimation {
  bool _alreadyUpdate = false;
  final FlameAnimation.Animation animation;

  ControlledUpdateAnimation(this.animation);

  void render(Canvas canvas, Rect position) {
    if (position == null) return;
    if (animation != null && animation.loaded()) {
      animation.getSprite().renderRect(canvas, position);
    }
    _alreadyUpdate = false;
  }

  void update(double dt) {
    if (!_alreadyUpdate) {
      _alreadyUpdate = true;
      animation?.update(dt);
    }
  }
}
