import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/rpg_game.dart';
import 'package:flame/components/mixins/has_game_ref.dart';
import 'package:flame/text_config.dart';

class TextDamage extends TextComponent with HasGameRef<RPGGame> {
  final String text;
  final TextConfig config;
  final Position initPosition;
  bool destroyed = false;
  Position position;
  double initialY;
  double velocity = -4;
  double gravity = 0.5;
  double moveAxisX = 0;
  TextDamage(this.text, this.initPosition,
      {this.config = const TextConfig(fontSize: 10)})
      : super(text, config: config) {
    position = initPosition;
    initialY = position.y;
    moveAxisX = Random().nextInt(100) % 2 == 0 ? -1 : 1;
    setByPosition(position);
  }

  @override
  bool destroy() => destroyed;

  @override
  void update(double t) {
    setByPosition(Position(
      position.x,
      position.y,
    ));
    position.y += velocity;
    position.x += moveAxisX;
    velocity += gravity;

    if (position.y > initialY + 16) {
      remove();
    }

    super.update(t);
  }

  void remove() {
    destroyed = true;
  }
}
