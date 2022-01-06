import 'package:bonfire/bonfire.dart';
import 'package:example/shared/player/knight.dart';
import 'package:flutter/material.dart';

class BarLifeComponent extends InterfaceComponent {
  double padding = 20;
  double widthBar = 90;
  double strokeWidth = 12;

  double maxLife = 0;
  double life = 0;
  double maxStamina = 100;
  double stamina = 0;

  BarLifeComponent()
      : super(
          id: 1,
          position: Vector2(20, 20),
          sprite: Sprite.load('health_ui.png'),
          size: Vector2(120, 40),
        );

  @override
  void update(double dt) {
    if (this.gameRef.player != null) {
      life = this.gameRef.player?.life ?? 0.0;
      maxLife = this.gameRef.player?.maxLife ?? 0.0;
      if (this.gameRef.player is Knight) {
        stamina = (this.gameRef.player as Knight).stamina;
      }
    }
    super.update(dt);
  }

  @override
  void render(Canvas c) {
    super.render(c);
    try {
      _drawLife(c);
      _drawStamina(c);
    } catch (e) {}
  }

  void _drawLife(Canvas canvas) {
    double xBar = position.x + 26;
    double yBar = position.y + 10;
    canvas.drawLine(
        Offset(xBar, yBar),
        Offset(xBar + widthBar, yBar),
        Paint()
          ..color = Colors.blueGrey[800]!
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
    double xBar = position.x + 26;
    double yBar = position.y + 28;

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
}
