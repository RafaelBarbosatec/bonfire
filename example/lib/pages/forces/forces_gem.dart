import 'package:bonfire/bonfire.dart';
import 'package:example/pages/mini_games/platform/platform_spritesheet.dart';
import 'package:flutter/material.dart';

class ForcesGem extends GameDecoration
    with Movement, HandleForces, BlockMovementCollision {
  final String text;
  final bool execMoveDown;
  late TextPaint _textPaint;
  late Vector2 initPosition;
  ForcesGem({
    required Vector2 position,
    this.text = 'AccelerationForce',
    Force2D? force,
    this.execMoveDown = false,
  }) : super.withAnimation(
          animation: PlatformSpritesheet.gem,
          position: position,
          size: Vector2(15, 13),
        ) {
    initPosition = position.clone();
    force.let(addForce);
    if (execMoveDown) {
      moveDown();
    }
    _textPaint = TextPaint(
      style: TextStyle(
        fontSize: size.x / 4,
        color: Colors.white,
      ),
    );
  }

  @override
  Future<void> onLoad() {
    add(RectangleHitbox(size: size));
    var textSize = _textPaint.getLineMetrics(text).size;
    add(
      TextComponent(
        text: text,
        position: Vector2((textSize.x / -2) + size.x / 2, textSize.y * -1.2),
        textRenderer: _textPaint,
      ),
    );
    return super.onLoad();
  }

  void reset() {
    position = initPosition.clone();
    if (execMoveDown) {
      moveDown();
    }
  }
}
