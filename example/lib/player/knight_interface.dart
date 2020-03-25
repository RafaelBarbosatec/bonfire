import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:example/player/knight.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';

class KnightInterface extends GameInterface {
  double maxLife = 0;
  double life = 0;
  double maxStamina = 100;
  double stamina = 0;

  double widthBar = 90;
  double strokeWidth = 10;
  double padding = 20;
  Sprite healthBar;
  KnightInterface() {
    healthBar = Sprite('health_ui.png');
  }

  @override
  void update(double t) {
    if (this.gameRef.player != null) {
      life = this.gameRef.player.life;
      maxLife = this.gameRef.player.maxLife;
      if (this.gameRef.player is Knight) {
        stamina = (this.gameRef.player as Knight).stamina;
      }
    }
    super.update(t);
  }

  @override
  void render(Canvas c) {
    try {
      _drawLife(c);
      _drawStamina(c);
    } catch (e) {}
    _drawSprite(c);
    super.render(c);
  }

  void _drawLife(Canvas canvas) {
    double xBar = 49;
    double yBar = 31.5;
    canvas.drawLine(
        Offset(xBar, yBar),
        Offset(xBar + widthBar, yBar),
        Paint()
          ..color = Colors.blueGrey[800]
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.fill);

    double currentBarLife = (life * widthBar) / maxLife;

    canvas.drawLine(
        Offset(xBar, yBar),
        Offset(xBar + currentBarLife, yBar),
        Paint()
          ..color = _getColorLife(currentBarLife)
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.fill);
  }

  void _drawStamina(Canvas canvas) {
    double xBar = 49;
    double yBar = 48;

    double currentBarStamina = (stamina * widthBar) / maxStamina;

    canvas.drawLine(
        Offset(xBar, yBar),
        Offset(xBar + currentBarStamina, yBar),
        Paint()
          ..color = Colors.yellow
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.fill);
  }

  Color _getColorLife(double currentBarLife) {
    if (currentBarLife > widthBar - (widthBar / 3)) {
      return Colors.green;
    }
    if (currentBarLife > (widthBar / 3)) {
      return Colors.yellow;
    } else {
      return Colors.red;
    }
  }

  void _drawSprite(Canvas c) {
    double w = 120;
    double factor = 0.3375;
    healthBar.renderRect(c, Rect.fromLTWH(padding, padding, w, w * factor));
  }
}
