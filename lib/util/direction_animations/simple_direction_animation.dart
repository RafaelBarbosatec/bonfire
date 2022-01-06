import 'dart:async';
import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/assets_loader.dart';

/// Class responsible to manager animation on `SimplePlayer` and `SimpleEnemy`
class SimpleDirectionAnimation {
  SpriteAnimation? idleLeft;
  SpriteAnimation? idleRight;
  SpriteAnimation? runLeft;
  SpriteAnimation? runRight;

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

  AssetsLoader? _loader = AssetsLoader();

  SpriteAnimation? _current;
  late SimpleAnimationEnum _currentType;
  AnimatedObjectOnce? _fastAnimation;
  Vector2 position = Vector2.zero();
  Vector2 size = Vector2.zero();

  bool runToTheEndFastAnimation = false;

  double opacity = 1.0;

  bool _flipX = false;
  bool _flipY = false;

  final bool enabledFlipX;
  final bool enabledFlipY;

  SimpleDirectionAnimation({
    required FutureOr<SpriteAnimation> idleRight,
    required FutureOr<SpriteAnimation> runRight,
    FutureOr<SpriteAnimation>? idleLeft,
    FutureOr<SpriteAnimation>? runLeft,
    FutureOr<SpriteAnimation>? idleUp,
    FutureOr<SpriteAnimation>? idleDown,
    FutureOr<SpriteAnimation>? idleUpLeft,
    FutureOr<SpriteAnimation>? idleUpRight,
    FutureOr<SpriteAnimation>? idleDownLeft,
    FutureOr<SpriteAnimation>? idleDownRight,
    FutureOr<SpriteAnimation>? runUp,
    FutureOr<SpriteAnimation>? runDown,
    FutureOr<SpriteAnimation>? runUpLeft,
    FutureOr<SpriteAnimation>? runUpRight,
    FutureOr<SpriteAnimation>? runDownLeft,
    FutureOr<SpriteAnimation>? runDownRight,
    Map<String, FutureOr<SpriteAnimation>>? others,
    SimpleAnimationEnum initAnimation = SimpleAnimationEnum.idleRight,
    this.enabledFlipX = true,
    this.enabledFlipY = false,
  }) {
    _currentType = initAnimation;
    _loader?.add(AssetToLoad(idleLeft, (value) => this.idleLeft = value));
    _loader?.add(AssetToLoad(idleRight, (value) => this.idleRight = value));
    _loader?.add(AssetToLoad(idleDown, (value) => this.idleDown = value));
    _loader?.add(AssetToLoad(idleUp, (value) => this.idleUp = value));
    _loader?.add(AssetToLoad(idleUpLeft, (value) => this.idleUpLeft = value));
    _loader?.add(AssetToLoad(idleUpRight, (value) {
      return this.idleUpRight = value;
    }));
    _loader?.add(AssetToLoad(idleDownLeft, (value) {
      return this.idleDownLeft = value;
    }));
    _loader?.add(AssetToLoad(idleDownRight, (value) {
      return this.idleDownRight = value;
    }));
    _loader?.add(AssetToLoad(runUp, (value) => this.runUp = value));
    _loader?.add(AssetToLoad(runRight, (value) => this.runRight = value));
    _loader?.add(AssetToLoad(runDown, (value) => this.runDown = value));
    _loader?.add(AssetToLoad(runLeft, (value) => this.runLeft = value));
    _loader?.add(AssetToLoad(runUpLeft, (value) => this.runUpLeft = value));
    _loader?.add(AssetToLoad(runUpRight, (value) => this.runUpRight = value));
    _loader?.add(AssetToLoad(runDownLeft, (value) {
      return this.runDownLeft = value;
    }));
    _loader?.add(AssetToLoad(runDownRight, (value) {
      return this.runDownRight = value;
    }));

    others?.forEach((key, anim) {
      _loader?.add(AssetToLoad(anim, (value) {
        return this.others[key] = value;
      }));
    });
  }

  /// Method used to play specific default animation
  void play(SimpleAnimationEnum animation) {
    _flipX = false;
    _flipY = false;
    _currentType = animation;
    if (!runToTheEndFastAnimation) {
      _fastAnimation = null;
    }
    switch (animation) {
      case SimpleAnimationEnum.idleLeft:
        if (idleLeft != null) {
          _current = idleLeft;
        } else if (enabledFlipX) {
          _flipX = true;
          _current = idleRight;
        }
        break;
      case SimpleAnimationEnum.idleRight:
        _current = idleRight;
        break;
      case SimpleAnimationEnum.idleUp:
        if (idleUp != null) _current = idleUp;
        break;
      case SimpleAnimationEnum.idleDown:
        if (idleDown != null) {
          _current = idleDown;
        } else if (enabledFlipY && idleUp != null) {
          _flipY = true;
          _current = idleUp;
        }
        break;
      case SimpleAnimationEnum.idleTopLeft:
        if (idleUpLeft != null) _current = idleUpLeft;
        break;
      case SimpleAnimationEnum.idleTopRight:
        if (idleUpRight != null) _current = idleUpRight;
        break;
      case SimpleAnimationEnum.idleDownLeft:
        if (idleDownLeft != null) _current = idleDownLeft;
        break;
      case SimpleAnimationEnum.idleDownRight:
        if (idleDownRight != null) _current = idleDownRight;
        break;
      case SimpleAnimationEnum.runUp:
        if (runUp != null) _current = runUp;
        break;
      case SimpleAnimationEnum.runRight:
        _current = runRight;
        break;
      case SimpleAnimationEnum.runDown:
        if (runDown != null) {
          _current = runDown;
        } else if (enabledFlipY && runUp != null) {
          _flipY = true;
          _current = runUp;
        }
        break;
      case SimpleAnimationEnum.runLeft:
        if (runLeft != null) {
          _current = runLeft;
        } else if (enabledFlipX) {
          _flipX = true;
          _current = runRight;
        }
        break;
      case SimpleAnimationEnum.runUpLeft:
        if (runUpLeft != null) _current = runUpLeft;
        break;
      case SimpleAnimationEnum.runUpRight:
        if (runUpRight != null) _current = runUpRight;
        break;
      case SimpleAnimationEnum.runDownLeft:
        if (runDownLeft != null) _current = runDownLeft;
        break;
      case SimpleAnimationEnum.runDownRight:
        if (runDownRight != null) _current = runDownRight;
        break;
      case SimpleAnimationEnum.custom:
        break;
    }
  }

  /// Method used to play specific animation registred in `others`
  void playOther(String key, {bool flipX = false, bool flipY = false}) {
    if (others.containsKey(key) == true) {
      if (!runToTheEndFastAnimation) {
        _fastAnimation = null;
      }
      _flipX = flipX;
      _flipY = flipY;
      _current = others[key];
      _currentType = SimpleAnimationEnum.custom;
    }
  }

  /// Method used to play animation once time
  Future playOnce(
    FutureOr<SpriteAnimation> animation, {
    VoidCallback? onFinish,
    bool runToTheEnd = false,
    bool flipX = false,
    bool flipY = false,
  }) async {
    runToTheEndFastAnimation = runToTheEnd;
    final anim = AnimatedObjectOnce(
      position: position,
      size: size,
      animation: animation,
      flipX: flipX,
      flipY: flipY,
      onFinish: () {
        onFinish?.call();
        _fastAnimation = null;
      },
    );
    await anim.onLoad();
    _fastAnimation = anim;
  }

  /// Method used to register new animation in others
  Future<void> addOtherAnimation(
    String key,
    FutureOr<SpriteAnimation> animation,
  ) async {
    others[key] = await animation;
  }

  void render(Canvas canvas) {
    if (_fastAnimation != null) {
      _fastAnimation?.render(canvas);
    } else {
      if (_flipX || _flipY) {
        canvas.save();
        Vector2 center = Vector2(
          position.x + size.x / 2,
          position.y + size.y / 2,
        );
        canvas.translate(center.x, center.y);
        canvas.scale(_flipX ? -1 : 1, _flipY ? -1 : 1);
        canvas.translate(-center.x, -center.y);
      }
      _current?.getSprite().renderWithOpacity(
            canvas,
            position,
            size,
            opacity: opacity,
          );

      if (_flipX || _flipY) {
        canvas.restore();
      }
    }
  }

  void update(double dt, Vector2 position, Vector2 size) {
    _fastAnimation?.opacity = opacity;
    _fastAnimation?.position = position;
    _fastAnimation?.size = size;
    _fastAnimation?.update(dt);

    this.position = position;
    this.size = size;
    _current?.update(dt);
  }

  Future<void> onLoad() async {
    await _loader?.load();
    _loader = null;
  }

  SimpleAnimationEnum? get currentType => _currentType;
}
