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

  SpriteAnimation? idleUp;
  SpriteAnimation? idleDown;
  SpriteAnimation? idleUpLeft;
  SpriteAnimation? idleUpRight;
  SpriteAnimation? idleDownLeft;
  SpriteAnimation? idleDownRight;
  SpriteAnimation? runUp;
  SpriteAnimation? runDown;
  SpriteAnimation? runUpLeft;
  SpriteAnimation? runUpRight;
  SpriteAnimation? runDownLeft;
  SpriteAnimation? runDownRight;

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
    Future<SpriteAnimation>? idleUp,
    Future<SpriteAnimation>? idleDown,
    Future<SpriteAnimation>? idleUpLeft,
    Future<SpriteAnimation>? idleUpRight,
    Future<SpriteAnimation>? idleDownLeft,
    Future<SpriteAnimation>? idleDownRight,
    Future<SpriteAnimation>? runUp,
    Future<SpriteAnimation>? runDown,
    Future<SpriteAnimation>? runUpLeft,
    Future<SpriteAnimation>? runUpRight,
    Future<SpriteAnimation>? runDownLeft,
    Future<SpriteAnimation>? runDownRight,
    Map<String, Future<SpriteAnimation>>? others,
    SimpleAnimationEnum initAnimation = SimpleAnimationEnum.idleRight,
  }) {
    _currentType = initAnimation;
    _loader.add(AssetToLoad(idleLeft, (value) => this.idleLeft = value));
    _loader.add(AssetToLoad(idleRight, (value) => this.idleRight = value));
    _loader.add(AssetToLoad(idleDown, (value) => this.idleDown = value));
    _loader.add(AssetToLoad(idleUp, (value) => this.idleUp = value));
    _loader.add(AssetToLoad(idleUpLeft, (value) => this.idleUpLeft = value));
    _loader.add(AssetToLoad(idleUpRight, (value) {
      return this.idleUpRight = value;
    }));
    _loader.add(AssetToLoad(idleDownLeft, (value) {
      return this.idleDownLeft = value;
    }));
    _loader.add(AssetToLoad(idleDownRight, (value) {
      return this.idleDownRight = value;
    }));
    _loader.add(AssetToLoad(runUp, (value) => this.runUp = value));
    _loader.add(AssetToLoad(runRight, (value) => this.runRight = value));
    _loader.add(AssetToLoad(runDown, (value) => this.runDown = value));
    _loader.add(AssetToLoad(runLeft, (value) => this.runLeft = value));
    _loader.add(AssetToLoad(runUpLeft, (value) => this.runUpLeft = value));
    _loader.add(AssetToLoad(runUpRight, (value) => this.runUpRight = value));
    _loader.add(AssetToLoad(runDownLeft, (value) {
      return this.runDownLeft = value;
    }));
    _loader.add(AssetToLoad(runDownRight, (value) {
      return this.runDownRight = value;
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
      case SimpleAnimationEnum.idleUp:
        if (idleUp != null) current = idleUp;
        break;
      case SimpleAnimationEnum.idleDown:
        if (idleDown != null) current = idleDown;
        break;
      case SimpleAnimationEnum.idleTopLeft:
        if (idleUpLeft != null) current = idleUpLeft;
        break;
      case SimpleAnimationEnum.idleTopRight:
        if (idleUpRight != null) current = idleUpRight;
        break;
      case SimpleAnimationEnum.idleDownLeft:
        if (idleDownLeft != null) current = idleDownLeft;
        break;
      case SimpleAnimationEnum.idleDownRight:
        if (idleDownRight != null) current = idleDownRight;
        break;
      case SimpleAnimationEnum.runUp:
        if (runUp != null) current = runUp;
        break;
      case SimpleAnimationEnum.runRight:
        current = runRight;
        break;
      case SimpleAnimationEnum.runDown:
        if (runDown != null) current = runDown;
        break;
      case SimpleAnimationEnum.runLeft:
        current = runLeft;
        break;
      case SimpleAnimationEnum.runUpLeft:
        if (runUpLeft != null) current = runUpLeft;
        break;
      case SimpleAnimationEnum.runUpRight:
        if (runUpRight != null) current = runUpRight;
        break;
      case SimpleAnimationEnum.runDownLeft:
        if (runDownLeft != null) current = runDownLeft;
        break;
      case SimpleAnimationEnum.runDownRight:
        if (runDownRight != null) current = runDownRight;
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

  Future playOnce(
    Future<SpriteAnimation> animation,
    Vector2Rect position, {
    VoidCallback? onFinish,
    bool runToTheEnd = false,
  }) async {
    runToTheEndFastAnimation = runToTheEnd;
    final anim = AnimatedObjectOnce(
      position: position,
      animation: animation,
      onFinish: () {
        onFinish?.call();
        _fastAnimation = null;
      },
    );
    await anim.onLoad();
    _fastAnimation = anim;
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
