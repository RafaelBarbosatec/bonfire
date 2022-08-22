import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';

class LinePathComponent extends GameComponent {
  final List<Offset> path;
  final Color color;
  final double strokeWidth;
  late Paint _paintPath;

  LinePathComponent(this.path, this.color, this.strokeWidth) {
    _paintPath = Paint()
      ..style = PaintingStyle.stroke
      ..color = color
      ..strokeWidth = strokeWidth;
  }

  @override
  void render(Canvas canvas) {
    if (path.isNotEmpty) {
      final p = Path()..moveTo(path.first.dx, path.first.dy);
      for (var i = 1; i < path.length; i++) {
        p.lineTo(path[i].dx, path[i].dy);
      }
      canvas.drawPath(p, _paintPath);
    }
    super.render(canvas);
  }

  @override
  int get priority => LayerPriority.MAP + 1;
}
