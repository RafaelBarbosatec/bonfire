import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/map/map_paint.dart';
import 'package:bonfire/util/vector2rect.dart';

class ControlledUpdateAnimation {
  bool _alreadyUpdate = false;
  final SpriteAnimation animation;

  ControlledUpdateAnimation(this.animation);

  void render(Canvas canvas, Vector2Rect position) {
    if (position == null) return;
    if (animation != null && animation.getSprite()?.loaded() == true) {
      animation.getSprite().render(
            canvas,
            position: position.position,
            size: position.size,
            overridePaint: MapPaint.instance.paint,
          );
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
