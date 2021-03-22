import 'dart:math';

import 'package:bonfire/base/rpg_game.dart';
import 'package:bonfire/util/priority_layer.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';

enum DirectionTextDamage { LEFT, RIGHT, RANDOM, NONE }

class TextDamageComponent extends TextComponent with HasGameRef<RPGGame> {
  final String text;
  final TextConfig config;
  final DirectionTextDamage direction;
  final double maxDownSize;
  bool destroyed = false;
  double _initialY;
  double _velocity;
  final double gravity;
  double _moveAxisX = 0;
  final bool onlyUp;

  TextDamageComponent(
    this.text,
    Offset position, {
    this.onlyUp = false,
    this.config,
    double initVelocityTop = -4,
    this.maxDownSize = 20,
    this.gravity = 0.5,
    this.direction = DirectionTextDamage.RANDOM,
  }) : super(
          text,
          config: (config ?? TextConfig(fontSize: 10)),
          position: Vector2(position.dx, position.dy),
        ) {
    _initialY = position.dy;
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
  }

  @override
  bool destroy() => destroyed;

  @override
  void update(double t) {
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
  int get priority => PriorityLayer.OBJECTS;
}
