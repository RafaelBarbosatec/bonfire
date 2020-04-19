import 'dart:ui';

import 'package:bonfire/util/objects/sprite_object.dart';
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
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;

  Tile(
    String spritePath,
    Position position, {
    this.collision = false,
    this.size = 32,
  }) {
    this.position = positionInWorld = generateRectWithBleedingPixel(position);
    if (spritePath.isNotEmpty) sprite = Sprite(spritePath);

    _textConfig = TextConfig(
      fontSize: size / 3.5,
    );
    _positionText = Position(position.x, position.y);
  }

  Tile.fromSprite(
    Sprite sprite,
    Position position, {
    this.collision = false,
    this.size = 32,
  }) {
    this.sprite = sprite;
    this.position = positionInWorld = generateRectWithBleedingPixel(position);

    _textConfig = TextConfig(
      fontSize: size / 3.5,
    );
    _positionText = Position(position.x, position.y);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (gameRef != null && gameRef.constructionMode && isVisibleInMap())
      _drawGrid(canvas);
  }

  void _drawGrid(Canvas canvas) {
    canvas.drawRect(
      position,
      _paintText..color = gameRef.map.colorConstructMode,
    );
    if (_positionText.x % 2 == 0) {
      _textConfig
          .withColor(
            gameRef.map.colorConstructMode,
          )
          .render(
            canvas,
            '${_positionText.x.toInt()}:${_positionText.y.toInt()}',
            Position(position.left + 2, position.top + 2),
          );
    }
  }

  Rect generateRectWithBleedingPixel(Position position) {
    return Rect.fromLTWH(
      (position.x * size) - (position.x % 2 == 0 ? 0.5 : 0),
      (position.y * size) - (position.y % 2 == 0 ? 0.5 : 0),
      size + (position.x % 2 == 0 ? 1 : 0),
      size + (position.y % 2 == 0 ? 1 : 0),
    );
  }
}
