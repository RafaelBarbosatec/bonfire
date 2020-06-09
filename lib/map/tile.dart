import 'dart:ui';

import 'package:bonfire/util/objects/sprite_object.dart';
import 'package:flame/position.dart';
import 'package:flame/sprite.dart';
import 'package:flame/text_config.dart';
import 'package:flutter/material.dart';

class Tile extends SpriteObject {
  final bool collision;
  final double width;
  final double height;
  Position _positionText;
  Paint _paintText = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;

  Tile(
    String spritePath,
    Position position, {
    this.collision = false,
    this.width = 32,
    this.height = 32,
  }) {
    this.position = generateRectWithBleedingPixel(position, width, height);
    if (spritePath.isNotEmpty) sprite = Sprite(spritePath);

    _positionText = Position(position.x, position.y);
  }

  Tile.fromSprite(
    Sprite sprite,
    Position position, {
    this.collision = false,
    this.width = 32,
    this.height = 32,
  }) {
    this.sprite = sprite;
    this.position = generateRectWithBleedingPixel(position, width, height);

    _positionText = Position(position.x, position.y);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (gameRef != null && gameRef.showCollisionArea && collision)
      _drawCollision(canvas);
    if (gameRef != null && gameRef.constructionMode && isVisibleInCamera())
      _drawGrid(canvas);
  }

  void _drawGrid(Canvas canvas) {
    canvas.drawRect(
      position,
      _paintText
        ..color = gameRef.constructionModeColor ?? Colors.cyan.withOpacity(0.5),
    );
    if (_positionText.x % 2 == 0) {
      TextConfig(
        fontSize: width / 3.5,
      )
          .withColor(
            gameRef.constructionModeColor ?? Colors.cyan.withOpacity(0.5),
          )
          .render(
            canvas,
            '${_positionText.x.toInt()}:${_positionText.y.toInt()}',
            Position(position.left + 2, position.top + 2),
          );
    }
  }

  Rect generateRectWithBleedingPixel(
      Position position, double width, double height) {
    double bleendingWidthPixel = width * 0.03;
    if (bleendingWidthPixel > 2) {
      bleendingWidthPixel = 2;
    }
    double bleendingHeightPixel = width * 0.03;
    if (bleendingHeightPixel > 2) {
      bleendingHeightPixel = 2;
    }
    return Rect.fromLTWH(
      (position.x * width) -
          (position.x % 2 == 0 ? (bleendingWidthPixel / 2) : 0),
      (position.y * height) -
          (position.y % 2 == 0 ? (bleendingHeightPixel / 2) : 0),
      width + (position.x % 2 == 0 ? bleendingWidthPixel : 0),
      height + (position.y % 2 == 0 ? bleendingHeightPixel : 0),
    );
  }

  void _drawCollision(Canvas canvas) {
    canvas.drawRect(
      position,
      new Paint()
        ..color = gameRef.collisionAreaColor ??
            Colors.lightGreenAccent.withOpacity(0.5),
    );
  }
}
