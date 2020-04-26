import 'dart:ui';

import 'package:bonfire/util/world_component.dart';
import 'package:flame/sprite.dart';

class SpriteObject extends WorldComponent {
  Sprite sprite;

  @override
  void render(Canvas canvas) {
    if (sprite != null && position != null && sprite.loaded())
      sprite.renderRect(canvas, position);
  }
}
