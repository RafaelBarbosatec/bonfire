import 'package:bonfire/bonfire.dart';
import 'package:example/shared/interface/bar_life_controller.dart';
import 'package:flutter/material.dart';

class BarLifeInterface extends InterfaceComponent {
  final double padding = 20;
  final double widthBar = 90;
  final double strokeWidth = 12;
  late BarLifeController controller;

  BarLifeInterface()
      : super(
          id: 1,
          position: Vector2(20, 20),
          spriteUnselected: Sprite.load('health_ui.png'),
          size: Vector2(120, 40),
        );

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    try {
      _drawLife(canvas);
      _drawStamina(canvas);
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  @override
  void onMount() {
    controller = BarLifeController();
    super.onMount();
  }

  void _drawLife(Canvas canvas) {
    double xBar = 26;
    double yBar = 10;
    canvas.drawLine(
        Offset(xBar, yBar),
        Offset(xBar + widthBar, yBar),
        Paint()
          ..color = Colors.blueGrey[800]!
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.fill);

    double currentBarLife = (controller.life * widthBar) / controller.maxLife;

    canvas.drawLine(
        Offset(xBar, yBar),
        Offset(xBar + currentBarLife, yBar),
        Paint()
          ..color = _getColorLife(currentBarLife)
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.fill);
  }

  void _drawStamina(Canvas canvas) {
    double xBar = 26;
    double yBar = 28;

    double currentBarStamina =
        (controller.stamina * widthBar) / controller.maxStamina;

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
