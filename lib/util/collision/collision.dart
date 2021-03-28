import 'package:flutter/widgets.dart';

class CollisionArea {
  double height;
  double width;
  final Offset align;

  CollisionArea(
      {this.height = 0.0, this.width = 0.0, this.align = const Offset(0, 0)});

  CollisionArea.fromSize(double size, {this.align = const Offset(0, 0)}) {
    width = size;
    height = size;
  }

  Rect getRect(Rect displacement) {
    double left = displacement.left + align.dx;
    double top = displacement.top + align.dy;
    return Rect.fromLTWH(left, top, width, height);
  }
}
