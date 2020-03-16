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
  Position positionInWorld;
  double initialY;
  double velocity = -4;
  double gravity = 0.5;
  double moveAxisX = 0;
  TextDamage(this.text, this.initPosition,
      {this.config = const TextConfig(fontSize: 10)})
      : super(text, config: config) {
    positionInWorld = initPosition;
    initialY = positionInWorld.y;
    moveAxisX = Random().nextInt(100) % 2 == 0 ? -1 : 1;
    setByPosition(positionInWorld);
  }

  @override
  void update(double t) {
    setByPosition(Position(
      positionInWorld.x + gameRef.mapCamera.x,
      positionInWorld.y + gameRef.mapCamera.y,
    ));
    positionInWorld.y += velocity;
    positionInWorld.x += moveAxisX;
    velocity += gravity;

    if (positionInWorld.y > initialY) {
      remove();
    }

    super.update(t);
  }

  void remove() {
    destroyed = true;
  }

  @override
  bool destroy() {
    return destroyed;
  }
}
