import 'package:flutter/widgets.dart';

class Collision {
  final double height;
  final double width;
  final Offset align;

  Collision(
      {this.height = 0.0, this.width = 0.0, this.align = const Offset(0, 0)});
}
