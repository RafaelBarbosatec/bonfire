import 'package:bonfire/bonfire.dart';
import 'package:example/shared/util/person_sprite_sheet.dart';
import 'package:flutter/material.dart';

class RageEnemy extends SimpleEnemy {
  late TextPaint _textPaint;
  final String text = 'RangeEnemy';
  RageEnemy({
    required Vector2 position,
  }) : super(
          position: position,
          animation: PersionSpritesheet(path: 'orc.png').simpleAnimarion(),
          size: Vector2.all(24),
          speed: 20,
        ) {
    _textPaint = TextPaint(
      style: TextStyle(
        fontSize: size.x / 5,
        color: Colors.white,
      ),
    );
  }

  @override
  void update(double dt) {
    seeAndMoveToAttackRange();
    super.update(dt);
  }

  @override
  Future<void> onLoad() {
    /// Adds rectangle collision
    add(RectangleHitbox(size: size / 2, position: size / 4));
    var textSize = _textPaint.measureText(text);
    add(
      TextComponent(
        text: text,
        position: Vector2((textSize.x / -2) + size.x / 2, -2),
        textRenderer: _textPaint,
      ),
    );
    return super.onLoad();
  }
}
