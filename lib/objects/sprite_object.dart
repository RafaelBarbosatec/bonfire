import 'dart:ui';

import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/util/priority_layer.dart';
import 'package:flame/sprite.dart';

class SpriteObject extends GameComponent {
  Sprite sprite;

  @override
  void render(Canvas canvas) {
    if (sprite != null && position != null && sprite.loaded())
      sprite.renderRect(canvas, position);
  }

  @override
  int priority() => PriorityLayer.OBJECTS;
}
