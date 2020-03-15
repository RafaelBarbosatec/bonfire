import 'package:flame/sprite.dart';
import 'package:flutter/widgets.dart';

enum JoystickActionAlign { TOP, BOTTOM }

class JoystickAction {
  final int actionId;
  final String pathSprite;
  final String pathSpritePressed;
  final double size;
  final double marginTop;
  final double marginBottom;
  final double marginRight;
  final JoystickActionAlign align;

  Rect rect;
  Sprite _sprite;

  JoystickAction({
    @required this.actionId,
    @required this.pathSprite,
    this.pathSpritePressed,
    this.size = 20,
    this.marginTop = 0,
    this.marginBottom = 0,
    this.marginRight = 0,
    this.align = JoystickActionAlign.BOTTOM,
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
