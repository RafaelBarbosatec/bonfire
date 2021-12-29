import 'package:flutter/painting.dart';

class GameColorFilter {
  Color? color;
  BlendMode blendMode;

  GameColorFilter({this.color, this.blendMode = BlendMode.color});

  bool get enable => color != null;
}
