import 'dart:math';

import 'package:bonfire/base/bonfire_game.dart';
import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/priority_layer.dart';
import 'package:flame/components/mixins/has_game_ref.dart';
import 'package:flame/text_config.dart';

enum DirectionTextDamage { LEFT, RIGHT, RANDOM, NONE }

class TextDamageComponent extends TextComponent with HasGameRef<BonfireGame> {
  final String text;
  final TextConfig config;
  final Position initPosition;
  final DirectionTextDamage direction;
  final double maxDownSize;
  bool destroyed = false;
  Position position;
  double _initialY;
  double _velocity;
  final double gravity;
  double _moveAxisX = 0;
  final bool onlyUp;

  TextDamageComponent(
    this.text,
    this.initPosition, {
    this.onlyUp = false,
    this.config,
    double initVelocityTop = -4,
    this.maxDownSize = 20,
    this.gravity = 0.5,
    this.direction = DirectionTextDamage.RANDOM,
  }) : super(text, config: (config ?? TextConfig(fontSize: 10))) {
    position = initPosition;
    _initialY = position.y;
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

    position.y += _velocity;
    position.x += _moveAxisX;
    _velocity += gravity;

    if (onlyUp && _velocity >= 0) {
      remove();
    }
    if (position.y > _initialY + maxDownSize) {
      remove();
    }

    super.update(t);
  }

  void remove() {
    destroyed = true;
  }

  @override
  int priority() => PriorityLayer.OBJECTS;
}
