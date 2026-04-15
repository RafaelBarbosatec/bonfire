import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:example/shared/util/common_sprite_sheet.dart';
import 'package:flutter/material.dart';

class BarrelTap extends GameDecoration
    with TapGesture, Movement, HandleForces, BlockMovementCollision {
  late TextPaint _textPaint;
  final String text = 'Touch me';
  BarrelTap({required Vector2 position})
      : super.withSprite(
          sprite: CommonSpriteSheet.barrelSprite,
          position: position,
          size: Vector2.all(16),
        ) {
    addForce(ResistanceForce2D(id: 'resi', value: Vector2.all(5)));
  }

  @override
  void onTap() {
    double randomAngle = Random().nextDouble() * pi * 2;
    moveFromAngle(randomAngle);
  }

  @override
  Future<void> onLoad() {
    add(RectangleHitbox(size: size));
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
