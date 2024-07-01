import 'dart:async';
import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/direction_animations/render_transform_warpper.dart';
import 'package:bonfire/util/sprite_animation_render.dart';

/// Class responsible to manager animation on `SimplePlayer` and `SimpleEnemy`
class SimpleDirectionAnimation {
  SpriteAnimation? _idleLeftAnim;
  SpriteAnimation? _idleRightAnim;
  SpriteAnimation? _runLeftAnim;
  SpriteAnimation? _runRightAnim;

  SpriteAnimation? _idleUpAnim;
  SpriteAnimation? _idleDownAnim;
  SpriteAnimation? _idleUpLeftAnim;
  SpriteAnimation? _idleUpRightAnim;
  SpriteAnimation? _idleDownLeftAnim;
  SpriteAnimation? _idleDownRightAnim;
  SpriteAnimation? _runUpAnim;
  SpriteAnimation? _runDownAnim;
  SpriteAnimation? _runUpLeftAnim;
  SpriteAnimation? _runUpRightAnim;
  SpriteAnimation? _runDownLeftAnim;
  SpriteAnimation? _runDownRightAnim;
  Vector2? centerAnchor;

  Map<dynamic, SpriteAnimation> others = {};

  AssetsLoader? _loader = AssetsLoader();

  final SpriteAnimationRender _current = SpriteAnimationRender();
  SimpleAnimationEnum? _currentType;
  SpriteAnimationRender? _fastAnimation;
  Vector2 size = Vector2.zero();

  bool runToTheEndFastAnimation = false;

  bool enabledFlipX;
  bool enabledFlipY;

  bool _isFlipHorizontally = false;
  bool _isFlipVertically = false;

  bool get isFlipHorizontally => _isFlipHorizontally;
  set isFlipHorizontally(bool value) {
    _isFlipHorizontally = value;
    if (_fastAnimationUseCompFlip) {
      isFlipHorizontallyFastAnimation = value;
    }
  }

  bool get isFlipVertically => _isFlipVertically;
  set isFlipVertically(bool value) {
    _isFlipVertically = value;
    if (_fastAnimationUseCompFlip) {
      isFlipVerticallyFastAnimation = value;
    }
  }

  BonfireGameInterface? gameRef;

  bool eightDirection;
  SimpleAnimationEnum? lastPlayedAnimation = SimpleAnimationEnum.idleDown;
  SimpleAnimationEnum? beforeLastPlayedAnimation = SimpleAnimationEnum.idleDown;

  bool _playing = true;
  dynamic _currentKeyCustom;

  Paint? _strockePaint;
  double _strokeWidth = 0;
  Vector2 _strokeSize = Vector2.zero();
  Vector2 _strokePosition = Vector2.zero();
  Vector2? spriteAnimationOffset;

  bool isFlipHorizontallyFastAnimation = false;
  bool isFlipVerticallyFastAnimation = false;

  bool get _needDoFlip => isFlipHorizontally || isFlipVertically;
  bool get _needDoFlipFastAnimation =>
      isFlipHorizontallyFastAnimation || isFlipVerticallyFastAnimation;

  bool get canRunDown =>
      _runDownAnim != null || (_runUpAnim != null && enabledFlipY == true);
  bool get canIdleDown =>
      _idleDownAnim != null || (_idleDownAnim != null && enabledFlipY == true);
  bool get canRunUp => _runUpAnim != null;
  bool get canRunUpLeft => _runUpLeftAnim != null;
  bool get canRunUpRight => _runUpRightAnim != null;
  bool get canRunDownLeft => _runDownLeftAnim != null;
  bool get canRunDownRight => _runDownRightAnim != null;
  bool get canIdleUp => _idleUpAnim != null;

  late RenderTransformWrapper _renderWrapper;
  late RenderTransformWrapper _fastAnimationRenderWrapper;

  int get currentIndex => _current.currentIndex;
  int get fastAnimationcurrentIndex => _fastAnimation?.currentIndex ?? 0;

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
    Map<dynamic, FutureOr<SpriteAnimation>>? others,
    this.enabledFlipX = true,
    this.enabledFlipY = false,
    this.eightDirection = false,
    this.centerAnchor,
  }) {
    _loader?.add(AssetToLoad(idleLeft, (value) => _idleLeftAnim = value));
    _loader?.add(AssetToLoad(idleRight, (value) => _idleRightAnim = value));
    _loader?.add(AssetToLoad(idleDown, (value) => _idleDownAnim = value));
    _loader?.add(AssetToLoad(idleUp, (value) => _idleUpAnim = value));
    _loader?.add(AssetToLoad(idleUpLeft, (value) => _idleUpLeftAnim = value));
    _loader?.add(AssetToLoad(idleUpRight, (value) => _idleUpRightAnim = value));
    _loader?.add(
      AssetToLoad(idleDownLeft, (value) => _idleDownLeftAnim = value),
    );
    _loader?.add(
      AssetToLoad(idleDownRight, (value) => _idleDownRightAnim = value),
    );
    _loader?.add(AssetToLoad(runUp, (value) => _runUpAnim = value));
    _loader?.add(AssetToLoad(runRight, (value) => _runRightAnim = value));
    _loader?.add(AssetToLoad(runDown, (value) => _runDownAnim = value));
    _loader?.add(AssetToLoad(runLeft, (value) => _runLeftAnim = value));
    _loader?.add(AssetToLoad(runUpLeft, (value) => _runUpLeftAnim = value));
    _loader?.add(AssetToLoad(runUpRight, (value) => _runUpRightAnim = value));
    _loader?.add(AssetToLoad(runDownLeft, (value) => _runDownLeftAnim = value));
    _loader?.add(
      AssetToLoad(runDownRight, (value) => _runDownRightAnim = value),
    );

    others?.forEach((key, anim) {
      _loader?.add(AssetToLoad(anim, (value) {
        return this.others[key] = value;
      }));
    });

    _renderWrapper = RenderTransformWrapper(
      transforms: [
        FlipRenderTransform(
          _flipRenderTransform,
        ),
        CenterAdjustRenderTransform(
          _adjustRenderTransform,
        )
      ],
      render: _myRender,
    );
    _fastAnimationRenderWrapper = RenderTransformWrapper(
      transforms: [
        FlipRenderTransform(
          _flipFastAnimationRenderTransform,
        ),
        CenterAdjustRenderTransform(
          _adjustRenderTransform,
        )
      ],
      render: _myFastAnimationRender,
    );
  }

  CenterAdjustRenderData? _adjustRenderTransform() {
    if (centerAnchor != null) {
      return CenterAdjustRenderData(
        center: (size / 2),
        newCenter: centerAnchor!,
      );
    }
    return null;
  }

  FlipRenderTransformData? _flipRenderTransform() {
    if (_needDoFlip) {
      return FlipRenderTransformData(
        center: (size / 2),
        horizontal: isFlipHorizontally,
        vertical: isFlipVertically,
      );
    }
    return null;
  }

  FlipRenderTransformData? _flipFastAnimationRenderTransform() {
    if (_fastAnimation != null && _needDoFlipFastAnimation) {
      return FlipRenderTransformData(
        center: (size / 2),
        horizontal: isFlipHorizontallyFastAnimation,
        vertical: isFlipVerticallyFastAnimation,
      );
    }
    return null;
  }

  /// Method used to play specific default animation
  void play(SimpleAnimationEnum animation) {
    if (_currentType == animation) return;
    isFlipHorizontally = false;
    isFlipVertically = false;

    _currentType = animation;
    _currentKeyCustom = null;
    if (!runToTheEndFastAnimation) {
      _fastAnimation?.onFinish?.call();
      _fastAnimation = null;
    }
    switch (animation) {
      case SimpleAnimationEnum.idleLeft:
        _idleLeft();
        break;
      case SimpleAnimationEnum.idleRight:
        _current.animation = _idleRightAnim;
        break;
      case SimpleAnimationEnum.idleUp:
        if (_idleUpAnim != null) _current.animation = _idleUpAnim;
        break;
      case SimpleAnimationEnum.idleDown:
        if (_idleDownAnim != null) {
          _current.animation = _idleDownAnim;
        } else if (enabledFlipY && _idleUpAnim != null) {
          isFlipVertically = true;
          _current.animation = _idleUpAnim;
        }
        break;
      case SimpleAnimationEnum.idleUpLeft:
        if (_idleUpLeftAnim != null) {
          _current.animation = _idleUpLeftAnim;
        } else if (_idleUpRightAnim != null) {
          _current.animation = _idleUpRightAnim;
          isFlipHorizontally = true;
        } else {
          _idleLeft();
        }
        break;
      case SimpleAnimationEnum.idleUpRight:
        if (_idleUpRightAnim != null) {
          _current.animation = _idleUpRightAnim;
        } else {
          _current.animation = _idleRightAnim;
        }
        break;
      case SimpleAnimationEnum.idleDownLeft:
        if (_idleDownLeftAnim != null) {
          _current.animation = _idleDownLeftAnim;
        } else if (_idleDownRightAnim != null) {
          _current.animation = _idleDownRightAnim;
          isFlipHorizontally = true;
        } else {
          _idleLeft();
        }
        break;
      case SimpleAnimationEnum.idleDownRight:
        if (_idleDownRightAnim != null) {
          _current.animation = _idleDownRightAnim;
        } else {
          _current.animation = _idleRightAnim;
        }
        break;
      case SimpleAnimationEnum.runUp:
        if (eightDirection) {
          if (lastPlayedAnimation == SimpleAnimationEnum.runRight ||
              lastPlayedAnimation == SimpleAnimationEnum.runLeft) {
            if (beforeLastPlayedAnimation == SimpleAnimationEnum.runUpRight) {
              _current.animation = _runUpRightAnim;
            } else if (beforeLastPlayedAnimation ==
                SimpleAnimationEnum.runUpLeft) {
              _current.animation = _runUpLeftAnim;
            } else if (_runUpAnim != null) {
              _current.animation = _runUpAnim;
            }
          } else if (_runUpAnim != null) {
            _current.animation = _runUpAnim;
          }
          _changeLastAnimation(SimpleAnimationEnum.runUp);
        } else if (_runUpAnim != null) {
          _current.animation = _runUpAnim;
        }
        break;
      case SimpleAnimationEnum.runRight:
        _runRight();
        break;
      case SimpleAnimationEnum.runDown:
        if (eightDirection) {
          if (lastPlayedAnimation == SimpleAnimationEnum.runRight ||
              lastPlayedAnimation == SimpleAnimationEnum.runLeft) {
            if (beforeLastPlayedAnimation == SimpleAnimationEnum.runDownRight) {
              _current.animation = _runDownRightAnim;
            } else if (beforeLastPlayedAnimation ==
                SimpleAnimationEnum.runDownLeft) {
              _current.animation = _runDownLeftAnim;
            } else {
              if (_runDownAnim != null) {
                _current.animation = _runDownAnim;
              } else if (enabledFlipY && _runUpAnim != null) {
                isFlipVertically = true;
                _current.animation = _runUpAnim;
              }
            }
          } else {
            if (_runDownAnim != null) {
              _current.animation = _runDownAnim;
            } else if (enabledFlipY && _runUpAnim != null) {
              isFlipVertically = true;
              _current.animation = _runUpAnim;
            }
          }
          _changeLastAnimation(SimpleAnimationEnum.runDown);
        } else {
          if (_runDownAnim != null) {
            _current.animation = _runDownAnim;
          } else if (enabledFlipY && _runUpAnim != null) {
            isFlipVertically = true;
            _current.animation = _runUpAnim;
          }
        }
        break;
      case SimpleAnimationEnum.runLeft:
        _runLeft();
        break;
      case SimpleAnimationEnum.runUpLeft:
        if (_runUpLeftAnim != null) {
          _current.animation = _runUpLeftAnim;
          _changeLastAnimation(SimpleAnimationEnum.runUpLeft);
        } else if (_runUpRightAnim != null) {
          _current.animation = _runUpRightAnim;
          isFlipHorizontally = true;
          _changeLastAnimation(SimpleAnimationEnum.runUpLeft);
        } else {
          _runLeft();
        }
        break;
      case SimpleAnimationEnum.runUpRight:
        if (_runUpRightAnim != null) {
          _current.animation = _runUpRightAnim;
          _changeLastAnimation(SimpleAnimationEnum.runUpRight);
        } else {
          _runRight();
        }
        break;
      case SimpleAnimationEnum.runDownLeft:
        if (_runDownLeftAnim != null) {
          _current.animation = _runDownLeftAnim;
          _changeLastAnimation(SimpleAnimationEnum.runDownLeft);
        } else if (_runDownRightAnim != null) {
          _current.animation = _runDownRightAnim;
          isFlipHorizontally = true;
          _changeLastAnimation(SimpleAnimationEnum.runDownLeft);
        } else {
          _runLeft();
        }
        break;
      case SimpleAnimationEnum.runDownRight:
        if (_runDownRightAnim != null) {
          _current.animation = _runDownRightAnim;
          _changeLastAnimation(SimpleAnimationEnum.runDownRight);
        } else {
          _runRight();
        }
        break;
      case SimpleAnimationEnum.custom:
        break;
    }
  }

  /// Method used to play specific animation registred in `others`
  void playOther(dynamic key, {bool? flipX, bool? flipY}) {
    if (containOther(key) &&
        (_currentKeyCustom != key || _checkFlipIsDiffrent(flipX, flipY))) {
      if (!runToTheEndFastAnimation) {
        _fastAnimation = null;
      }
      isFlipHorizontally = flipX ?? (isFlipHorizontally);
      isFlipVertically = flipY ?? (isFlipVertically);
      _current.animation = others[key];
      _currentKeyCustom = key;
      _currentType = SimpleAnimationEnum.custom;
    }
  }

  bool _checkFlipIsDiffrent(bool? flipX, bool? flipY) {
    return (flipX != null && flipX != isFlipHorizontally) ||
        (flipY != null && flipY != isFlipVertically);
  }

  bool containOther(dynamic key) => others.containsKey(key);

  bool _fastAnimationUseCompFlip = false;

  /// Method used to play animation once time
  Future<void> playOnce(
    FutureOr<SpriteAnimation> animation, {
    VoidCallback? onFinish,
    VoidCallback? onStart,
    bool runToTheEnd = false,
    bool flipX = false,
    bool flipY = false,
    bool useCompFlip = false,
    Vector2? size,
    Vector2? offset,
  }) async {
    _fastAnimationUseCompFlip = useCompFlip;
    final completer = Completer();
    _fastAnimation?.onFinish?.call();
    runToTheEndFastAnimation = runToTheEnd;
    if (useCompFlip) {
      isFlipHorizontallyFastAnimation = isFlipHorizontally;
      isFlipVerticallyFastAnimation = isFlipVertically;
    } else {
      isFlipHorizontallyFastAnimation = flipX;
      isFlipVerticallyFastAnimation = flipY;
    }
    _fastAnimation = SpriteAnimationRender(
      size: size ?? this.size,
      position: offset,
      animation: await animation,
      loop: false,
      onFinish: () {
        onFinish?.call();
        _fastAnimation = null;
        completer.complete();
      },
    );
    onStart?.call();
    return completer.future;
  }

  /// Method used to play animation once time
  Future<void> playOnceOther(
    dynamic key, {
    VoidCallback? onFinish,
    VoidCallback? onStart,
    bool runToTheEnd = false,
    bool flipX = false,
    bool flipY = false,
    bool useCompFlip = false,
    Vector2? size,
    Vector2? offset,
  }) async {
    if (others.containsKey(key) != true) {
      return Future.value();
    }
    _fastAnimationUseCompFlip = useCompFlip;
    final completer = Completer();
    _fastAnimation?.onFinish?.call();
    runToTheEndFastAnimation = runToTheEnd;
    if (useCompFlip) {
      isFlipHorizontallyFastAnimation = isFlipHorizontally;
      isFlipVerticallyFastAnimation = isFlipVertically;
    } else {
      isFlipHorizontallyFastAnimation = flipX;
      isFlipVerticallyFastAnimation = flipY;
    }

    _fastAnimation = SpriteAnimationRender(
      size: size ?? this.size,
      position: offset,
      animation: others[key],
      loop: false,
      onFinish: () {
        onFinish?.call();
        _fastAnimation = null;
        completer.complete();
      },
    );
    onStart?.call();

    return completer.future;
  }

  /// Method used to register new animation in others
  Future<void> addOtherAnimation(
    dynamic key,
    FutureOr<SpriteAnimation> animation,
  ) async {
    others[key] = await animation;
  }

  void update(
    double dt,
    Vector2 size,
  ) {
    this.size = size;
    if (_playing) {
      _fastAnimation?.update(dt);
      _current.size = size;
      _current.update(dt);
    }
    if (_strokeSize.isZero()) {
      _strokeSize = Vector2(
        size.x + _strokeWidth * 2,
        size.y + _strokeWidth * 2,
      );
    }
  }

  void _changeLastAnimation(SimpleAnimationEnum lastAnimation) {
    beforeLastPlayedAnimation = lastPlayedAnimation;
    lastPlayedAnimation = lastAnimation;
  }

  Future<void> onLoad(BonfireGameInterface gameRef) async {
    this.gameRef = gameRef;
    await _loader?.load();
    _loader = null;
  }

  SimpleAnimationEnum? get currentType => _currentType;

  void pause() => _playing = false;

  void resume() => _playing = true;

  void _runLeft() {
    if (eightDirection) {
      if (lastPlayedAnimation == SimpleAnimationEnum.runUpLeft ||
          lastPlayedAnimation == SimpleAnimationEnum.runDownLeft) {
        if (beforeLastPlayedAnimation == SimpleAnimationEnum.runDown) {
          _current.animation = _runDownLeftAnim;
        } else if (beforeLastPlayedAnimation == SimpleAnimationEnum.runUp) {
          _current.animation = _runUpLeftAnim;
        } else {
          if (_runLeftAnim != null) {
            _current.animation = _runLeftAnim;
          } else if (enabledFlipX) {
            isFlipHorizontally = true;
            if (_fastAnimationUseCompFlip) {
              isFlipHorizontallyFastAnimation = isFlipHorizontally;
            }
            _current.animation = _runRightAnim;
          }
        }
      } else {
        if (_runLeftAnim != null) {
          _current.animation = _runLeftAnim;
        } else if (enabledFlipX) {
          isFlipHorizontally = true;
          _current.animation = _runRightAnim;
        }
      }
      _changeLastAnimation(SimpleAnimationEnum.runLeft);
    } else {
      if (_runLeftAnim != null) {
        _current.animation = _runLeftAnim;
      } else if (enabledFlipX) {
        isFlipHorizontally = true;
        _current.animation = _runRightAnim;
      }
    }
  }

  void _runRight() {
    if (eightDirection) {
      if (lastPlayedAnimation == SimpleAnimationEnum.runUpRight ||
          lastPlayedAnimation == SimpleAnimationEnum.runDownRight) {
        if (beforeLastPlayedAnimation == SimpleAnimationEnum.runDown) {
          _current.animation = _runDownRightAnim;
        } else if (beforeLastPlayedAnimation == SimpleAnimationEnum.runUp) {
          _current.animation = _runUpRightAnim;
        } else {
          _current.animation = _runRightAnim;
        }
      } else {
        _current.animation = _runRightAnim;
      }
      _changeLastAnimation(SimpleAnimationEnum.runRight);
    } else {
      _current.animation = _runRightAnim;
    }
  }

  void _idleLeft() {
    if (_idleLeftAnim != null) {
      _current.animation = _idleLeftAnim;
    } else if (enabledFlipX) {
      isFlipHorizontally = true;
      _current.animation = _idleRightAnim;
    }
  }

  void showStroke(Color color, double width, {Vector2? offset}) {
    if (_strockePaint != null &&
        _strokeWidth == width &&
        _strockePaint?.color == color) {
      return;
    }
    _strokeWidth = width;
    _strokePosition = Vector2.all(-_strokeWidth);
    if (offset != null) {
      _strokePosition += offset;
    }
    _strokeSize = Vector2.zero();
    _strockePaint = Paint()
      ..color = color
      ..colorFilter = ColorFilter.mode(
        color,
        BlendMode.srcATop,
      );
  }

  void hideStroke() {
    _strockePaint = null;
  }

  void render(Canvas canvas, Paint paint) {
    if (_fastAnimation != null) {
      _fastAnimationRenderWrapper.execRender(canvas, paint);
    } else {
      _renderWrapper.execRender(canvas, paint);
    }
  }

  void _myRender(Canvas canvas, Paint paint) {
    _renderCurrentAnimation(canvas, paint);
  }

  void _myFastAnimationRender(Canvas canvas, Paint paint) {
    _renderFastAnimation(canvas, paint);
  }

  void _renderCurrentAnimation(Canvas canvas, Paint paint) {
    if (_strockePaint != null) {
      _current.render(
        canvas,
        overridePaint: _strockePaint,
        size: _strokeSize,
        position: _strokePosition + (spriteAnimationOffset ?? Vector2.zero()),
      );
    }
    _current.render(
      canvas,
      overridePaint: paint,
      position: spriteAnimationOffset,
    );
  }

  void _renderFastAnimation(Canvas canvas, Paint paint) {
    if (_strockePaint != null) {
      _fastAnimation?.render(
        canvas,
        overridePaint: _strockePaint!,
        size: _strokeSize,
        position: _strokePosition + (spriteAnimationOffset ?? Vector2.zero()),
      );
    }
    _fastAnimation?.render(
      canvas,
      overridePaint: paint,
      position: spriteAnimationOffset,
    );
  }
}
