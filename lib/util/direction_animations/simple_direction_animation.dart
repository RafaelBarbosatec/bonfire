import 'dart:async';
import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/sprite_animation_render.dart';

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

  Map<dynamic, SpriteAnimation> others = {};

  AssetsLoader? _loader = AssetsLoader();

  final SpriteAnimationRender _current = SpriteAnimationRender();
  SimpleAnimationEnum? _currentType;
  SpriteAnimationRender? _fastAnimation;
  Vector2 size = Vector2.zero();

  bool runToTheEndFastAnimation = false;

  bool enabledFlipX;
  bool enabledFlipY;

  bool isFlipHorizontally = false;
  bool isFlipVertically = false;

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
  }) {
    _loader?.add(AssetToLoad(idleLeft, (value) => this.idleLeft = value));
    _loader?.add(AssetToLoad(idleRight, (value) => this.idleRight = value));
    _loader?.add(AssetToLoad(idleDown, (value) => this.idleDown = value));
    _loader?.add(AssetToLoad(idleUp, (value) => this.idleUp = value));
    _loader?.add(AssetToLoad(idleUpLeft, (value) => this.idleUpLeft = value));
    _loader?.add(AssetToLoad(idleUpRight, (value) => this.idleUpRight = value));
    _loader?.add(
      AssetToLoad(idleDownLeft, (value) => this.idleDownLeft = value),
    );
    _loader?.add(
      AssetToLoad(idleDownRight, (value) => this.idleDownRight = value),
    );
    _loader?.add(AssetToLoad(runUp, (value) => this.runUp = value));
    _loader?.add(AssetToLoad(runRight, (value) => this.runRight = value));
    _loader?.add(AssetToLoad(runDown, (value) => this.runDown = value));
    _loader?.add(AssetToLoad(runLeft, (value) => this.runLeft = value));
    _loader?.add(AssetToLoad(runUpLeft, (value) => this.runUpLeft = value));
    _loader?.add(AssetToLoad(runUpRight, (value) => this.runUpRight = value));
    _loader?.add(AssetToLoad(runDownLeft, (value) => this.runDownLeft = value));
    _loader?.add(
      AssetToLoad(runDownRight, (value) => this.runDownRight = value),
    );

    others?.forEach((key, anim) {
      _loader?.add(AssetToLoad(anim, (value) {
        return this.others[key] = value;
      }));
    });
  }

  /// Method used to play specific default animation
  void play(SimpleAnimationEnum animation) {
    if (_currentType == animation) return;
    isFlipHorizontally = false;
    isFlipVertically = false;

    _currentType = animation;
    _currentKeyCustom = null;
    if (!runToTheEndFastAnimation) {
      _fastAnimation = null;
    }
    switch (animation) {
      case SimpleAnimationEnum.idleLeft:
        _idleLeft();
        break;
      case SimpleAnimationEnum.idleRight:
        _current.animation = idleRight;
        break;
      case SimpleAnimationEnum.idleUp:
        if (idleUp != null) _current.animation = idleUp;
        break;
      case SimpleAnimationEnum.idleDown:
        if (idleDown != null) {
          _current.animation = idleDown;
        } else if (enabledFlipY && idleUp != null) {
          isFlipVertically = true;
          _current.animation = idleUp;
        }
        break;
      case SimpleAnimationEnum.idleUpLeft:
        if (idleUpLeft != null) {
          _current.animation = idleUpLeft;
        } else if (idleUpRight != null) {
          _current.animation = idleUpRight;
          isFlipHorizontally = true;
        } else {
          _idleLeft();
        }
        break;
      case SimpleAnimationEnum.idleUpRight:
        if (idleUpRight != null) {
          _current.animation = idleUpRight;
        } else {
          _current.animation = idleRight;
        }
        break;
      case SimpleAnimationEnum.idleDownLeft:
        if (idleDownLeft != null) {
          _current.animation = idleDownLeft;
        } else if (idleDownRight != null) {
          _current.animation = idleDownRight;
          isFlipHorizontally = true;
        } else {
          _idleLeft();
        }
        break;
      case SimpleAnimationEnum.idleDownRight:
        if (idleDownRight != null) {
          _current.animation = idleDownRight;
        } else {
          _current.animation = idleRight;
        }
        break;
      case SimpleAnimationEnum.runUp:
        if (eightDirection) {
          if (lastPlayedAnimation == SimpleAnimationEnum.runRight ||
              lastPlayedAnimation == SimpleAnimationEnum.runLeft) {
            if (beforeLastPlayedAnimation == SimpleAnimationEnum.runUpRight) {
              _current.animation = runUpRight;
            } else if (beforeLastPlayedAnimation ==
                SimpleAnimationEnum.runUpLeft) {
              _current.animation = runUpLeft;
            } else if (runUp != null) {
              _current.animation = runUp;
            }
          } else if (runUp != null) {
            _current.animation = runUp;
          }
          _changeLastAnimation(SimpleAnimationEnum.runUp);
        } else if (runUp != null) {
          _current.animation = runUp;
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
              _current.animation = runDownRight;
            } else if (beforeLastPlayedAnimation ==
                SimpleAnimationEnum.runDownLeft) {
              _current.animation = runDownLeft;
            } else {
              if (runDown != null) {
                _current.animation = runDown;
              } else if (enabledFlipY && runUp != null) {
                isFlipVertically = true;
                _current.animation = runUp;
              }
            }
          } else {
            if (runDown != null) {
              _current.animation = runDown;
            } else if (enabledFlipY && runUp != null) {
              isFlipVertically = true;
              _current.animation = runUp;
            }
          }
          _changeLastAnimation(SimpleAnimationEnum.runDown);
        } else {
          if (runDown != null) {
            _current.animation = runDown;
          } else if (enabledFlipY && runUp != null) {
            isFlipVertically = true;
            _current.animation = runUp;
          }
        }
        break;
      case SimpleAnimationEnum.runLeft:
        _runLeft();
        break;
      case SimpleAnimationEnum.runUpLeft:
        if (runUpLeft != null) {
          _current.animation = runUpLeft;
          _changeLastAnimation(SimpleAnimationEnum.runUpLeft);
        } else if (runUpRight != null) {
          _current.animation = runUpRight;
          isFlipHorizontally = true;
          _changeLastAnimation(SimpleAnimationEnum.runUpLeft);
        } else {
          _runLeft();
        }
        break;
      case SimpleAnimationEnum.runUpRight:
        if (runUpRight != null) {
          _current.animation = runUpRight;
          _changeLastAnimation(SimpleAnimationEnum.runUpRight);
        } else {
          _runRight();
        }
        break;
      case SimpleAnimationEnum.runDownLeft:
        if (runDownLeft != null) {
          _current.animation = runDownLeft;
          _changeLastAnimation(SimpleAnimationEnum.runDownLeft);
        } else if (runDownRight != null) {
          _current.animation = runDownRight;
          isFlipHorizontally = true;
          _changeLastAnimation(SimpleAnimationEnum.runDownLeft);
        } else {
          _runLeft();
        }
        break;
      case SimpleAnimationEnum.runDownRight:
        if (runDownRight != null) {
          _current.animation = runDownRight;
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

  /// Method used to play animation once time
  Future playOnce(
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
    runToTheEndFastAnimation = runToTheEnd;
    bool lastFlipX = isFlipHorizontally;
    bool lastFlipY = isFlipVertically;
    _fastAnimation = SpriteAnimationRender(
      size: size ?? this.size,
      position: offset,
      animation: await animation,
      loop: false,
      onFinish: () {
        onFinish?.call();
        _fastAnimation = null;
        if (!useCompFlip) {
          isFlipHorizontally = lastFlipX;
          isFlipVertically = lastFlipY;
        }
      },
    );
    if (!useCompFlip) {
      isFlipVertically = flipY;
      isFlipHorizontally = flipX;
    }
    onStart?.call();
  }

  /// Method used to play animation once time
  Future playOnceOther(
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
    runToTheEndFastAnimation = runToTheEnd;
    bool lastFlipX = isFlipHorizontally;
    bool lastFlipY = isFlipVertically;
    _fastAnimation = SpriteAnimationRender(
      size: size ?? this.size,
      position: offset,
      animation: others[key],
      loop: false,
      onFinish: () {
        onFinish?.call();
        _fastAnimation = null;
        if (!useCompFlip) {
          isFlipHorizontally = lastFlipX;
          isFlipVertically = lastFlipY;
        }
      },
    );
    if (!useCompFlip) {
      isFlipVertically = flipY;
      isFlipHorizontally = flipX;
    }
    onStart?.call();
  }

  /// Method used to register new animation in others
  Future<void> addOtherAnimation(
    dynamic key,
    FutureOr<SpriteAnimation> animation,
  ) async {
    others[key] = await animation;
  }

  bool get needDoFlip => isFlipHorizontally || isFlipVertically;

  void render(Canvas canvas, Paint paint) {
    if (needDoFlip) {
      Vector2 center = (size / 2);
      canvas.save();
      canvas.translate(center.x, center.y);
      canvas.scale(isFlipHorizontally ? -1 : 1, isFlipVertically ? -1 : 1);
      canvas.translate(-center.x, -center.y);
    }

    if (_fastAnimation != null) {
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
    } else {
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
    if (needDoFlip) {
      canvas.restore();
    }
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
          _current.animation = runDownLeft;
        } else if (beforeLastPlayedAnimation == SimpleAnimationEnum.runUp) {
          _current.animation = runUpLeft;
        } else {
          if (runLeft != null) {
            _current.animation = runLeft;
          } else if (enabledFlipX) {
            isFlipHorizontally = true;
            _current.animation = runRight;
          }
        }
      } else {
        if (runLeft != null) {
          _current.animation = runLeft;
        } else if (enabledFlipX) {
          isFlipHorizontally = true;
          _current.animation = runRight;
        }
      }
      _changeLastAnimation(SimpleAnimationEnum.runLeft);
    } else {
      if (runLeft != null) {
        _current.animation = runLeft;
      } else if (enabledFlipX) {
        isFlipHorizontally = true;
        _current.animation = runRight;
      }
    }
  }

  void _runRight() {
    if (eightDirection) {
      if (lastPlayedAnimation == SimpleAnimationEnum.runUpRight ||
          lastPlayedAnimation == SimpleAnimationEnum.runDownRight) {
        if (beforeLastPlayedAnimation == SimpleAnimationEnum.runDown) {
          _current.animation = runDownRight;
        } else if (beforeLastPlayedAnimation == SimpleAnimationEnum.runUp) {
          _current.animation = runUpRight;
        } else {
          _current.animation = runRight;
        }
      } else {
        _current.animation = runRight;
      }
      _changeLastAnimation(SimpleAnimationEnum.runRight);
    } else {
      _current.animation = runRight;
    }
  }

  void _idleLeft() {
    if (idleLeft != null) {
      _current.animation = idleLeft;
    } else if (enabledFlipX) {
      isFlipHorizontally = true;
      _current.animation = idleRight;
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
}
