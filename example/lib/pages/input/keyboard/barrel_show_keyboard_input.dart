import 'package:bonfire/bonfire.dart';
import 'package:example/shared/util/common_sprite_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BarrelShowKeyboardInput extends GameDecoration
    with KeyboardEventListener {
  late TextPaint _textPaint;
  final String base = 'Use your keyboard: \n {input}';
  String text = '';
  String input = '';
  BarrelShowKeyboardInput({required Vector2 position})
      : super.withSprite(
          sprite: CommonSpriteSheet.barrelSprite,
          position: position,
          size: Vector2.all(16),
        ) {
    _textPaint = TextPaint(
      style: TextStyle(
        fontSize: size.x / 4,
        color: Colors.white,
      ),
    );
  }

  @override
  void render(Canvas canvas) {
    _textPaint.render(canvas, text, Vector2(0, size.y));
    super.render(canvas);
  }

  @override
  void update(double dt) {
    text = base.replaceAll('{input}', input);
    super.update(dt);
  }

  @override
  bool onKeyboard(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    input += event.character ?? '';
    return true;
  }
}
