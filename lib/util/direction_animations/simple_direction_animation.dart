import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/objects/animated_object_once.dart';
import 'package:bonfire/util/direction_animations/simple_animation_enum.dart';
import 'package:bonfire/util/vector2rect.dart';
import 'package:flutter/foundation.dart';

class SimpleDirectionAnimation {
  final SpriteAnimation idleLeft;
  final SpriteAnimation idleRight;
  final SpriteAnimation idleTop;
  final SpriteAnimation idleBottom;
  final SpriteAnimation idleTopLeft;
  final SpriteAnimation idleTopRight;
  final SpriteAnimation idleBottomLeft;
  final SpriteAnimation idleBottomRight;
  final SpriteAnimation runTop;
  final SpriteAnimation runRight;
  final SpriteAnimation runBottom;
  final SpriteAnimation runLeft;
  final SpriteAnimation runTopLeft;
  final SpriteAnimation runTopRight;
  final SpriteAnimation runBottomLeft;
  final SpriteAnimation runBottomRight;
  final Map<String, SpriteAnimation> others;
  final SimpleAnimationEnum init;

  SpriteAnimation current;
  SimpleAnimationEnum _currentType;
  AnimatedObjectOnce _fastAnimation;
  bool runToTheEndFastAnimation = false;
  Vector2Rect position;

  SimpleDirectionAnimation({
    @required this.idleLeft,
    @required this.idleRight,
    this.idleTop,
    this.idleBottom,
    this.idleTopLeft,
    this.idleTopRight,
    this.idleBottomLeft,
    this.idleBottomRight,
    this.runTop,
    @required this.runRight,
    this.runBottom,
    @required this.runLeft,
    this.runTopLeft,
    this.runTopRight,
    this.runBottomLeft,
    this.runBottomRight,
    this.others,
    this.init = SimpleAnimationEnum.idleRight,
  }) {
    play(init);
  }

  void play(SimpleAnimationEnum animation) {
    _currentType = animation;
    if (!runToTheEndFastAnimation) {
      _fastAnimation = null;
    }
    switch (animation) {
      case SimpleAnimationEnum.idleLeft:
        if (idleLeft != null) current = idleLeft;
        break;
      case SimpleAnimationEnum.idleRight:
        if (idleRight != null) current = idleRight;
        break;
      case SimpleAnimationEnum.idleTop:
        if (idleTop != null) current = idleTop;
        break;
      case SimpleAnimationEnum.idleBottom:
        if (idleBottom != null) current = idleBottom;
        break;
      case SimpleAnimationEnum.idleTopLeft:
        if (idleTopLeft != null) current = idleTopLeft;
        break;
      case SimpleAnimationEnum.idleTopRight:
        if (idleTopRight != null) current = idleTopRight;
        break;
      case SimpleAnimationEnum.idleBottomLeft:
        if (idleBottomLeft != null) current = idleBottomLeft;
        break;
      case SimpleAnimationEnum.idleBottomRight:
        if (idleBottomRight != null) current = idleBottomRight;
        break;
      case SimpleAnimationEnum.runTop:
        if (runTop != null) current = runTop;
        break;
      case SimpleAnimationEnum.runRight:
        if (runRight != null) current = runRight;
        break;
      case SimpleAnimationEnum.runBottom:
        if (runBottom != null) current = runBottom;
        break;
      case SimpleAnimationEnum.runLeft:
        if (runLeft != null) current = runLeft;
        break;
      case SimpleAnimationEnum.runTopLeft:
        if (runTopLeft != null) current = runTopLeft;
        break;
      case SimpleAnimationEnum.runTopRight:
        if (runTopRight != null) current = runTopRight;
        break;
      case SimpleAnimationEnum.runBottomLeft:
        if (runBottomLeft != null) current = runBottomLeft;
        break;
      case SimpleAnimationEnum.runBottomRight:
        if (runBottomRight != null) current = runBottomRight;
        break;
    }
  }

  void playOther(String key) {
    if (others?.containsKey(key) == true) {
      if (!runToTheEndFastAnimation) {
        _fastAnimation = null;
      }
      current = others[key];
    }
  }

  void playOnce(
    SpriteAnimation animation, {
    VoidCallback onFinish,
    bool runToTheEnd = false,
  }) {
    runToTheEndFastAnimation = runToTheEnd;
    _fastAnimation = AnimatedObjectOnce(
      animation: animation,
      onFinish: () {
        onFinish?.call();
        _fastAnimation = null;
      },
    );
  }

  void render(Canvas canvas) {
    if (position == null) return;
    if (_fastAnimation != null) {
      _fastAnimation.render(canvas);
    } else {
      current.getSprite().render(
            canvas,
            position: position.position,
            size: position.size,
          );
    }
  }

  void update(double dt, Vector2Rect position) {
    this.position = position;
    if (_fastAnimation != null) {
      _fastAnimation.position = position;
      _fastAnimation.update(dt);
    } else {
      current?.update(dt);
    }
  }

  SimpleAnimationEnum get currentType => _currentType;
}
