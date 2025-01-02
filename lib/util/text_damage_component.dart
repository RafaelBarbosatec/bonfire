// ignore_for_file: constant_identifier_names

import 'dart:math';

import 'package:bonfire/util/bonfire_game_ref.dart';
import 'package:bonfire/util/priority_layer.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/cupertino.dart';

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
    double initVelocityVertical = -4,
    double initVelocityHorizontal = 1,
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
    _velocity = initVelocityVertical;
    switch (direction) {
      case DirectionTextDamage.LEFT:
        _moveAxisX = initVelocityHorizontal;
        break;
      case DirectionTextDamage.RIGHT:
        _moveAxisX = initVelocityHorizontal * -1;
        break;
      case DirectionTextDamage.RANDOM:
        _moveAxisX =
            initVelocityHorizontal * Random().nextInt(100) % 2 == 0 ? -1 : 1;
        break;
      case DirectionTextDamage.NONE:
        break;
    }
  }

  @override
  void render(Canvas canvas) {
    if (isRemoving) {
      return;
    }
    super.render(canvas);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isRemoving) {
      return;
    }
    position.y += _velocity;
    position.x += _moveAxisX;
    _velocity += gravity;

    if (onlyUp && _velocity >= 0) {
      removeFromParent();
    }

    if (gravity > 0) {
      if (position.y > _initialY + maxDownSize) {
        removeFromParent();
      }
    } else if (gravity < 0) {
      if (position.y < _initialY - maxDownSize) {
        removeFromParent();
      }
    }
  }

  @override
  int get priority => LayerPriority.getComponentPriority(position.y.round());
}
