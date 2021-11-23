import 'package:flutter/painting.dart';

class GameColorFilter {
  Color? color;
  BlendMode? blendMode;

  GameColorFilter({this.color, this.blendMode});

  bool get enable => color != null && blendMode != null;
}
