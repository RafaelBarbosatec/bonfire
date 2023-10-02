import 'package:bonfire/bonfire.dart';
import 'package:example/shared/util/common_sprite_sheet.dart';
import 'package:flutter/material.dart';

class BarrelDrag extends GameDecoration with DragGesture, Movement {
  late TextPaint _textPaint;
  final String text = 'Drag me';
  BarrelDrag({required Vector2 position})
      : super.withSprite(
          sprite: CommonSpriteSheet.barrelSprite,
          position: position,
          size: Vector2.all(16),
        );

  @override
  Future<void> onLoad() {
    _addsText();
    return super.onLoad();
  }

  void _addsText() {
    _textPaint = TextPaint(
      style: TextStyle(
        fontSize: size.x / 4,
        color: Colors.white,
      ),
    );
    var textSize = _textPaint.getLineMetrics(text).size;
    add(
      TextComponent(
        text: text,
        position: Vector2((textSize.x / -2) + size.x / 2, -5),
        textRenderer: _textPaint,
      ),
    );
  }
}
