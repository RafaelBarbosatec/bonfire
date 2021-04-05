import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/objects/animated_object_once.dart';
import 'package:bonfire/util/assets_loader.dart';
import 'package:bonfire/util/direction_animations/simple_animation_enum.dart';
import 'package:bonfire/util/vector2rect.dart';
import 'package:flutter/foundation.dart';

class SimpleDirectionAnimation {
  late SpriteAnimation idleLeft;
  late SpriteAnimation idleRight;
  late SpriteAnimation runLeft;
  late SpriteAnimation runRight;

  SpriteAnimation? idleTop;
  SpriteAnimation? idleBottom;
  SpriteAnimation? idleTopLeft;
  SpriteAnimation? idleTopRight;
  SpriteAnimation? idleBottomLeft;
  SpriteAnimation? idleBottomRight;
  SpriteAnimation? runTop;
  SpriteAnimation? runBottom;
  SpriteAnimation? runTopLeft;
  SpriteAnimation? runTopRight;
  SpriteAnimation? runBottomLeft;
  SpriteAnimation? runBottomRight;

  Map<String, SpriteAnimation> others = {};

  final _loader = AssetsLoader();

  SpriteAnimation? current;
  late SimpleAnimationEnum _currentType;
  AnimatedObjectOnce? _fastAnimation;
  Vector2Rect? position;

  bool runToTheEndFastAnimation = false;

  SimpleDirectionAnimation({
    required Future<SpriteAnimation> idleLeft,
    required Future<SpriteAnimation> idleRight,
    required Future<SpriteAnimation> runRight,
    required Future<SpriteAnimation> runLeft,
    Future<SpriteAnimation>? idleTop,
    Future<SpriteAnimation>? idleBottom,
    Future<SpriteAnimation>? idleTopLeft,
    Future<SpriteAnimation>? idleTopRight,
    Future<SpriteAnimation>? idleBottomLeft,
    Future<SpriteAnimation>? idleBottomRight,
    Future<SpriteAnimation>? runTop,
    Future<SpriteAnimation>? runBottom,
    Future<SpriteAnimation>? runTopLeft,
    Future<SpriteAnimation>? runTopRight,
    Future<SpriteAnimation>? runBottomLeft,
    Future<SpriteAnimation>? runBottomRight,
    Map<String, Future<SpriteAnimation>>? others,
    SimpleAnimationEnum initAnimation = SimpleAnimationEnum.idleRight,
  }) {
    _currentType = initAnimation;
    _loader.add(AssetToLoad(idleLeft, (value) => this.idleLeft = value));
    _loader.add(AssetToLoad(idleRight, (value) => this.idleRight = value));
    _loader.add(AssetToLoad(idleBottom, (value) => this.idleBottom = value));
    _loader.add(AssetToLoad(idleTopLeft, (value) => this.idleTopLeft = value));
    _loader.add(AssetToLoad(idleTopRight, (value) {
      return this.idleTopRight = value;
    }));
    _loader.add(AssetToLoad(idleBottomLeft, (value) {
      return this.idleBottomLeft = value;
    }));
    _loader.add(AssetToLoad(idleBottomRight, (value) {
      return this.idleBottomRight = value;
    }));
    _loader.add(AssetToLoad(runTop, (value) => this.runTop = value));
    _loader.add(AssetToLoad(runRight, (value) => this.runRight = value));
    _loader.add(AssetToLoad(runBottom, (value) => this.runBottom = value));
    _loader.add(AssetToLoad(runLeft, (value) => this.runLeft = value));
    _loader.add(AssetToLoad(runTopLeft, (value) => this.runTopLeft = value));
    _loader.add(AssetToLoad(runTopRight, (value) => this.runTopRight = value));
    _loader.add(AssetToLoad(runBottomLeft, (value) {
      return this.runBottomLeft = value;
    }));
    _loader.add(AssetToLoad(runBottomRight, (value) {
      return this.runBottomRight = value;
    }));

    others?.forEach((key, anim) {
      _loader.add(AssetToLoad(anim, (value) {
        return this.others[key] = value;
      }));
    });
  }

  void play(SimpleAnimationEnum animation) {
    _currentType = animation;
    if (!runToTheEndFastAnimation) {
      _fastAnimation = null;
    }
    switch (animation) {
      case SimpleAnimationEnum.idleLeft:
        current = idleLeft;
        break;
      case SimpleAnimationEnum.idleRight:
        current = idleRight;
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
        current = runRight;
        break;
      case SimpleAnimationEnum.runBottom:
        if (runBottom != null) current = runBottom;
        break;
      case SimpleAnimationEnum.runLeft:
        current = runLeft;
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
    if (others.containsKey(key) == true) {
      if (!runToTheEndFastAnimation) {
        _fastAnimation = null;
      }
      current = others[key];
    }
  }

  void playOnce(
    Future<SpriteAnimation> animation,
    Vector2Rect position, {
    VoidCallback? onFinish,
    bool runToTheEnd = false,
  }) {
    runToTheEndFastAnimation = runToTheEnd;
    _fastAnimation = AnimatedObjectOnce(
      position: position,
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
      _fastAnimation?.render(canvas);
    } else {
      current?.getSprite().renderFromVector2Rect(canvas, position!);
    }
  }

  void update(double dt, Vector2Rect position) {
    this.position = position;
    _fastAnimation?.position = position;
    _fastAnimation?.update(dt);
    current?.update(dt);
  }

  Future<void> onLoad() async {
    await _loader.load();
    play(_currentType);
  }

  SimpleAnimationEnum? get currentType => _currentType;
}
