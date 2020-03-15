import 'dart:ui';

import 'package:bonfire/rpg_game.dart';
import 'package:flame/components/component.dart';
import 'package:flame/components/mixins/has_game_ref.dart';
import 'package:flame/gestures.dart';
import 'package:flutter/widgets.dart';

class GameInterface extends Component with HasGameRef<RPGGame>, TapDetector {
  @override
  int priority() {
    return 10;
  }

  @override
  void render(Canvas c) {}

  @override
  void update(double t) {}
}
