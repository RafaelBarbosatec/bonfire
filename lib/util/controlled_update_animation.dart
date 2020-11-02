import 'dart:ui';

import 'package:flame/animation.dart' as FlameAnimation;

class ControlledUpdateAnimation {
  Paint _paint = Paint()..isAntiAlias = false;
  bool _alreadyUpdate = false;
  final FlameAnimation.Animation animation;

  ControlledUpdateAnimation(this.animation);

  void render(Canvas canvas, Rect position) {
    if (position == null) return;
    if (animation != null && animation.loaded()) {
      animation.getSprite().renderRect(canvas, position, overridePaint: _paint);
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
