import 'dart:ui';

import 'package:bonfire/util/sprite_object.dart';
import 'package:flame/position.dart';
import 'package:flame/sprite.dart';
import 'package:flame/text_config.dart';
import 'package:flutter/material.dart';

class Tile extends SpriteObject {
  final bool collision;
  final double size;
  TextConfig _textConfig;
  Position _positionText;
  Paint _paintText = Paint()
    ..color = Colors.lightBlueAccent.withOpacity(0.5)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;

  Tile(String spritePath, Position initPosition,
      {this.collision = false, this.size = 32}) {
    position = positionInWorld = Rect.fromLTWH(
      (initPosition != null ? initPosition.x : 0.0) * size,
      (initPosition != null ? initPosition.y : 0.0) * size,
      size,
      size,
    );
    if (spritePath.isNotEmpty) sprite = Sprite(spritePath);

    _textConfig = TextConfig(
      fontSize: size / 3.5,
      color: Colors.lightBlueAccent.withOpacity(0.4),
    );
    _positionText = Position(position.left / size, position.top / size);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (gameRef != null && gameRef.constructionMode) _drawGrid(canvas);
  }

  void _drawGrid(Canvas canvas) {
    canvas.drawRect(
      position,
      _paintText,
    );
    _textConfig.render(
      canvas,
      '${_positionText.x.toInt()}:${_positionText.y.toInt()}',
      Position(position.left + 2, position.top + 2),
    );
  }
}
