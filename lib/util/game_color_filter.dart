import 'package:bonfire/base/bonfire_game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

import 'bonfire_game_ref.dart';

class GameColorFilter with BonfireHasGameRef<BonfireGame> {
  Color? color;
  BlendMode? blendMode;

  GameColorFilter({this.color, this.blendMode});

  bool get enable => color != null && blendMode != null;
}
