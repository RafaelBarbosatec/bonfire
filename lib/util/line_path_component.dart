import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';

class LinePathComponent extends GameComponent {
  final List<Vector2> path;
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
      final p = Path()..moveTo(path.first.x, path.first.y);
      for (var i = 1; i < path.length; i++) {
        p.lineTo(path[i].x, path[i].y);
      }
      canvas.drawPath(p, _paintPath);
    }
    super.render(canvas);
  }

  @override
  int get priority => LayerPriority.MAP + 1;
}
