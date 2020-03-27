import 'dart:ui';

import 'package:bonfire/rpg_game.dart';
import 'package:flame/position.dart';
import 'package:flame/sprite.dart';
import 'package:flame/text_config.dart';
import 'package:flutter/material.dart';

class Tile {
  final String spriteImg;
  final bool collision;
  final double size;
  final Position initPosition;
  Rect _initRectPosition;
  Rect position;
  Sprite _sprite;
  RPGGame _game;
  TextConfig _textConfig;
  Position _positionText;
  Paint _paintText = Paint()
    ..color = Colors.lightBlueAccent.withOpacity(0.5)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;

  Tile(this.spriteImg, this.initPosition,
      {this.collision = false, this.size = 32}) {
    _initRectPosition = Rect.fromLTWH(
      (initPosition != null ? initPosition.x : 0.0) * size,
      (initPosition != null ? initPosition.y : 0.0) * size,
      size,
      size,
    );
    position = _initRectPosition;
    if (spriteImg.isNotEmpty) _sprite = Sprite(spriteImg);

    _textConfig = TextConfig(
        fontSize: size / 3.5, color: Colors.lightBlueAccent.withOpacity(0.4));
    _positionText = Position(position.left / size, position.top / size);
  }

  void render(Canvas canvas, Position camera) {
    if (_sprite != null && _sprite.loaded())
      _sprite.renderRect(canvas, position);

    if (_game != null && _game.constructionMode) _drawGrid(canvas);
  }

  void update(RPGGame game) {
    _game = game;
    position = Rect.fromLTWH(
      _initRectPosition.left + game.gameCamera.position.x,
      _initRectPosition.top + game.gameCamera.position.y,
      size,
      size,
    );
  }

  bool isVisible(RPGGame game) {
    _game = game;
    if (game.size == null) return false;
    return position.left > (size * -1) &&
        position.left < game.size.width + size &&
        position.top > (size * -1) &&
        position.top < game.size.height + size;
  }

  Rect get positionInWorld => Rect.fromLTWH(
        position.left - _game.gameCamera.position.x,
        position.top - _game.gameCamera.position.y,
        position.width,
        position.height,
      );

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
