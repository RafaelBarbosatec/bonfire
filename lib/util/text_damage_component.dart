// ignore_for_file: constant_identifier_names

import 'dart:math';

import 'package:bonfire/util/priority_layer.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/cupertino.dart';

import 'bonfire_game_ref.dart';

enum DirectionTextDamage { LEFT, RIGHT, RANDOM, NONE }

class TextDamageComponent extends TextComponent with BonfireHasGameRef {
  final DirectionTextDamage direction;
  final double maxDownSize;
  late double _initialY;
  late double _velocity;
  final double gravity;
  double _moveAxisX = 0;
  final bool onlyUp;

  TextDamageComponent(
    String text,
    Vector2 position, {
    this.onlyUp = false,
    TextStyle? config,
    double initVelocityTop = -4,
    this.maxDownSize = 20,
    this.gravity = 0.5,
    this.direction = DirectionTextDamage.RANDOM,
  }) : super(
          text: text,
          textRenderer: TextPaint(
            style: config,
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
  void render(Canvas canvas) {
    if (isRemoving) return;
    super.render(canvas);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isRemoving) return;
    position.y += _velocity;
    position.x += _moveAxisX;
    _velocity += gravity;

    if (onlyUp && _velocity >= 0) {
      removeFromParent();
    }
    if (position.y > _initialY + maxDownSize) {
      removeFromParent();
    }
  }

  @override
  int get priority => LayerPriority.getComponentPriority(position.y.round());
}
