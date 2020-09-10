import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/objects/animated_object_once.dart';
import 'package:flame/animation.dart';
import 'package:flutter/foundation.dart';

enum SimplePlayerAnimationEnum {
  idleLeft,
  idleRight,
  idleTop,
  idleBottom,
  idleTopLeft,
  idleTopRight,
  idleBottomLeft,
  idleBottomRight,
  runTop,
  runRight,
  runBottom,
  runLeft,
  runTopLeft,
  runTopRight,
  runBottomLeft,
  runBottomRight,
}

class SimplePlayerAnimation {
  final Animation idleLeft;
  final Animation idleRight;
  final Animation idleTop;
  final Animation idleBottom;
  final Animation idleTopLeft;
  final Animation idleTopRight;
  final Animation idleBottomLeft;
  final Animation idleBottomRight;
  final Animation runTop;
  final Animation runRight;
  final Animation runBottom;
  final Animation runLeft;
  final Animation runTopLeft;
  final Animation runTopRight;
  final Animation runBottomLeft;
  final Animation runBottomRight;
  final Map<String, Animation> others;
  final SimplePlayerAnimationEnum init;

  Animation _current;
  SimplePlayerAnimationEnum _currentType;
  AnimatedObjectOnce _fastAnimation;
  bool runToTheEndFastAnimation = false;

  SimplePlayerAnimation({
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
    this.init = SimplePlayerAnimationEnum.idleRight,
  }) {
    play(init);
  }

  void play(SimplePlayerAnimationEnum animation) {
    _currentType = animation;
    if (!runToTheEndFastAnimation) {
      _fastAnimation = null;
    }
    switch (animation) {
      case SimplePlayerAnimationEnum.idleLeft:
        if (idleLeft != null) _current = idleLeft;
        break;
      case SimplePlayerAnimationEnum.idleRight:
        if (idleRight != null) _current = idleRight;
        break;
      case SimplePlayerAnimationEnum.idleTop:
        if (idleTop != null) _current = idleTop;
        break;
      case SimplePlayerAnimationEnum.idleBottom:
        if (idleBottom != null) _current = idleBottom;
        break;
      case SimplePlayerAnimationEnum.idleTopLeft:
        if (idleTopLeft != null) _current = idleTopLeft;
        break;
      case SimplePlayerAnimationEnum.idleTopRight:
        if (idleTopRight != null) _current = idleTopRight;
        break;
      case SimplePlayerAnimationEnum.idleBottomLeft:
        if (idleBottomLeft != null) _current = idleBottomLeft;
        break;
      case SimplePlayerAnimationEnum.idleBottomRight:
        if (idleBottomRight != null) _current = idleBottomRight;
        break;
      case SimplePlayerAnimationEnum.runTop:
        if (runTop != null) _current = runTop;
        break;
      case SimplePlayerAnimationEnum.runRight:
        if (runRight != null) _current = runRight;
        break;
      case SimplePlayerAnimationEnum.runBottom:
        if (runBottom != null) _current = runBottom;
        break;
      case SimplePlayerAnimationEnum.runLeft:
        if (runLeft != null) _current = runLeft;
        break;
      case SimplePlayerAnimationEnum.runTopLeft:
        if (runTopLeft != null) _current = runTopLeft;
        break;
      case SimplePlayerAnimationEnum.runTopRight:
        if (runTopRight != null) _current = runTopRight;
        break;
      case SimplePlayerAnimationEnum.runBottomLeft:
        if (runBottomLeft != null) _current = runBottomLeft;
        break;
      case SimplePlayerAnimationEnum.runBottomRight:
        if (runBottomRight != null) _current = runBottomRight;
        break;
    }
  }

  void playOther(String key) {
    if (others?.containsKey(key) == true) {
      if (!runToTheEndFastAnimation) {
        _fastAnimation = null;
      }
      _current = others[key];
    }
  }

  void playOnce(
    Animation animation, {
    VoidCallback onFinish,
    bool runToTheEnd = false,
  }) {
    runToTheEndFastAnimation = runToTheEnd;
    _fastAnimation = AnimatedObjectOnce(
      animation: animation,
      onlyUpdate: true,
      onFinish: () {
        onFinish?.call();
        _fastAnimation = null;
      },
    );
  }

  void render(Canvas canvas, Rect position) {
    if (_fastAnimation != null) {
      if (_fastAnimation.loaded()) {
        _fastAnimation.animation.getSprite().renderRect(canvas, position);
      }
    } else {
      if (_current?.loaded() == true) {
        _current.getSprite().renderRect(canvas, position);
      }
    }
  }

  void update(double dt) {
    if (_fastAnimation != null) {
      _fastAnimation.update(dt);
    } else {
      _current?.update(dt);
    }
  }

  Animation get current => _current;
  SimplePlayerAnimationEnum get currentType => _currentType;
}
