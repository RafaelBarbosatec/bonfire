import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/rpg_game.dart';
import 'package:flame/components/mixins/has_game_ref.dart';
import 'package:flame/text_config.dart';

enum DirectionTextDamage { LEFT, RIGHT, RANDOM, NONE }

class TextDamage extends TextComponent with HasGameRef<RPGGame> {
  final String text;
  final TextConfig config;
  final Position initPosition;
  final DirectionTextDamage direction;
  bool destroyed = false;
  Position positionInWorld;
  double _initialY;
  double _velocity;
  final double gravity;
  double _moveAxisX = 0;

  TextDamage(
    this.text,
    this.initPosition, {
    this.config = const TextConfig(fontSize: 10),
    double initVelocityTop = -4,
    this.gravity = 0.5,
    this.direction = DirectionTextDamage.RANDOM,
  }) : super(text, config: config) {
    positionInWorld = initPosition;
    _initialY = positionInWorld.y;
    _velocity = initVelocityTop;
    switch (direction) {
      case DirectionTextDamage.LEFT:
        _moveAxisX = 1;
        break;
      case DirectionTextDamage.RIGHT:
        _moveAxisX = -1;
        break;
      case DirectionTextDamage.RANDOM:
        _moveAxisX = Random().nextInt(100) % 2 == 0 ? -1 : 1;
        break;
      case DirectionTextDamage.NONE:
        break;
    }
    setByPosition(positionInWorld);
  }

  @override
  void update(double t) {
    setByPosition(Position(
      positionInWorld.x + gameRef.gameCamera.position.x,
      positionInWorld.y + gameRef.gameCamera.position.y,
    ));
    positionInWorld.y += _velocity;
    positionInWorld.x += _moveAxisX;
    _velocity += gravity;

    if (positionInWorld.y > _initialY + 20) {
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
