import 'dart:ui';

import 'package:flame/animation.dart' as FlameAnimation;

class ControlledUpdateAnimation {
  bool alreadyUpdate = false;
  final FlameAnimation.Animation animation;

  ControlledUpdateAnimation(this.animation);

  void render(Canvas canvas, Rect position) {
    if (position == null) return;
    if (animation != null && animation.loaded()) {
      animation.getSprite().renderRect(canvas, position);
    }
    alreadyUpdate = false;
  }

  void update(double dt) {
    if (!alreadyUpdate) {
      alreadyUpdate = true;
      animation?.update(dt);
    }
  }
}
