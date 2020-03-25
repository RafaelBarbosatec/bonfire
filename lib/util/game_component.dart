import 'dart:ui';

import 'package:bonfire/rpg_game.dart';
import 'package:flame/components/component.dart';
import 'package:flame/components/mixins/has_game_ref.dart';

class GameComponent extends Component with HasGameRef<RPGGame> {
  @override
  void render(Canvas c) {}

  @override
  void update(double t) {}
}
