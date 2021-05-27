import 'dart:math';

import 'package:bonfire/base/bonfire_game.dart';
import 'package:bonfire/util/priority_layer.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';

enum DirectionTextDamage { LEFT, RIGHT, RANDOM, NONE }

class TextDamageComponent extends TextComponent with HasGameRef<BonfireGame> {
  final String text;
  final DirectionTextDamage direction;
  final double maxDownSize;
  late double _initialY;
  late double _velocity;
  final double gravity;
  double _moveAxisX = 0;
  final bool onlyUp;

  TextDamageComponent(
    this.text,
    Vector2 position, {
    this.onlyUp = false,
    TextPaintConfig? config,
    double initVelocityTop = -4,
    this.maxDownSize = 20,
    this.gravity = 0.5,
    this.direction = DirectionTextDamage.RANDOM,
  }) : super(
          text,
          textRenderer: TextPaint(
            config: config ?? TextPaintConfig(),
          ),
          position: position,
        ) {
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
  }

  @override
  void render(Canvas c) {
    if (shouldRemove) return;
    super.render(c);
  }

  @override
  void update(double t) {
    if (shouldRemove) return;
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

  @override
  int get priority => LayerPriority.getComponentPriority(position.y.round());
}
