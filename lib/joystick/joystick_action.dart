import 'package:flame/sprite.dart';
import 'package:flutter/widgets.dart';

enum JoystickActionAlign { TOP_LEFT, BOTTOM_LEFT, TOP_RIGHT, BOTTOM_RIGHT }

class JoystickAction {
  final int actionId;
  final String pathSprite;
  final String pathSpritePressed;
  final double size;
  final EdgeInsets margin;
  final JoystickActionAlign align;

  Rect rect;
  Sprite _sprite;

  JoystickAction({
    @required this.actionId,
    @required this.pathSprite,
    this.pathSpritePressed,
    this.size = 20,
    this.margin = EdgeInsets.zero,
    this.align = JoystickActionAlign.BOTTOM_RIGHT,
  }) {
    _sprite = Sprite(pathSprite);
  }

  void render(Canvas c) {
    if (rect != null) _sprite.renderRect(c, rect);
  }

  void pressed() {
    if (pathSpritePressed != null) {
      _sprite = Sprite(pathSpritePressed);
    }
  }

  void unPressed() {
    _sprite = Sprite(pathSprite);
  }
}
