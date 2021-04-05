import 'dart:ui';

import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/util/extensions.dart';
import 'package:flame/sprite.dart';

class SpriteObject extends GameComponent {
  Sprite? sprite;

  @override
  void render(Canvas canvas) {
    sprite?.renderFromVector2Rect(canvas, this.position);
  }
}
