import 'dart:async';
import 'dart:ui';

import 'package:bonfire/base/bonfire_game_interface.dart';
import 'package:bonfire/bonfire.dart';

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
  SimpleAnimationEnum? _currentType;
  AnimatedObjectOnce? _fastAnimation;
  Vector2 _fastAnimationOffset = Vector2.zero();
  Vector2 position = Vector2.zero();
  Vector2 size = Vector2.zero();
  final Vector2 _zero = Vector2.zero();

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
    if (!runToTheEndFastAnimation) {
      _fastAnimation = null;
    }
    switch (animation) {
      case SimpleAnimationEnum.idleLeft:
        _idleLeft();
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
          isFlipVertically = true;
          _current = idleUp;
        }
        break;
      case SimpleAnimationEnum.idleUpLeft:
        if (idleUpLeft != null) {
          _current = idleUpLeft;
        } else if (idleUpRight != null) {
          _current = idleUpRight;
          isFlipHorizontally = true;
        } else {
          _idleLeft();
        }
        break;
      case SimpleAnimationEnum.idleUpRight:
        if (idleUpRight != null) {
          _current = idleUpRight;
        } else {
          _current = idleRight;
        }
        break;
      case SimpleAnimationEnum.idleDownLeft:
        if (idleDownLeft != null) {
          _current = idleDownLeft;
        } else if (idleDownRight != null) {
          _current = idleDownRight;
          isFlipHorizontally = true;
        } else {
          _idleLeft();
        }
        break;
      case SimpleAnimationEnum.idleDownRight:
        if (idleDownRight != null) {
          _current = idleDownRight;
        } else {
          _current = idleRight;
        }
        break;
      case SimpleAnimationEnum.runUp:
        if (eightDirection) {
          if (lastPlayedAnimation == SimpleAnimationEnum.runRight ||
              lastPlayedAnimation == SimpleAnimationEnum.runLeft) {
            if (beforeLastPlayedAnimation == SimpleAnimationEnum.runUpRight) {
              _current = runUpRight;
            } else if (beforeLastPlayedAnimation ==
                SimpleAnimationEnum.runUpLeft) {
              _current = runUpLeft;
            } else if (runUp != null) {
              _current = runUp;
            }
          } else if (runUp != null) {
            _current = runUp;
          }
          changeLastAnimation(SimpleAnimationEnum.runUp);
        } else if (runUp != null) {
          _current = runUp;
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
              _current = runDownRight;
            } else if (beforeLastPlayedAnimation ==
                SimpleAnimationEnum.runDownLeft) {
              _current = runDownLeft;
            } else {
              if (runDown != null) {
                _current = runDown;
              } else if (enabledFlipY && runUp != null) {
                isFlipVertically = true;
                _current = runUp;
              }
            }
          } else {
            if (runDown != null) {
              _current = runDown;
            } else if (enabledFlipY && runUp != null) {
              isFlipVertically = true;
              _current = runUp;
            }
          }
          changeLastAnimation(SimpleAnimationEnum.runDown);
        } else {
          if (runDown != null) {
            _current = runDown;
          } else if (enabledFlipY && runUp != null) {
            isFlipVertically = true;
            _current = runUp;
          }
        }
        break;
      case SimpleAnimationEnum.runLeft:
        _runLeft();
        break;
      case SimpleAnimationEnum.runUpLeft:
        if (runUpLeft != null) {
          _current = runUpLeft;
          changeLastAnimation(SimpleAnimationEnum.runUpLeft);
        } else if (runUpRight != null) {
          _current = runUpRight;
          isFlipHorizontally = true;
          changeLastAnimation(SimpleAnimationEnum.runUpLeft);
        } else {
          _runLeft();
        }
        break;
      case SimpleAnimationEnum.runUpRight:
        if (runUpRight != null) {
          _current = runUpRight;
          changeLastAnimation(SimpleAnimationEnum.runUpRight);
        } else {
          _runRight();
        }
        break;
      case SimpleAnimationEnum.runDownLeft:
        if (runDownLeft != null) {
          _current = runDownLeft;
          changeLastAnimation(SimpleAnimationEnum.runDownLeft);
        } else if (runDownRight != null) {
          _current = runDownRight;
          isFlipHorizontally = true;
          changeLastAnimation(SimpleAnimationEnum.runDownLeft);
        } else {
          _runLeft();
        }
        break;
      case SimpleAnimationEnum.runDownRight:
        if (runDownRight != null) {
          _current = runDownRight;
          changeLastAnimation(SimpleAnimationEnum.runDownRight);
        } else {
          _runRight();
        }
        break;
      case SimpleAnimationEnum.custom:
        break;
    }
  }

  /// Method used to play specific animation registred in `others`
  void playOther(String key, {bool? flipX, bool? flipY}) {
    if (others.containsKey(key) == true) {
      if (!runToTheEndFastAnimation) {
        _fastAnimation = null;
      }
      isFlipHorizontally = flipX ?? (isFlipHorizontally);
      isFlipVertically = flipY ?? (isFlipVertically);
      _current = others[key];
      _currentType = SimpleAnimationEnum.custom;
    }
  }

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
    _fastAnimationOffset = offset ?? Vector2.zero();
    runToTheEndFastAnimation = runToTheEnd;
    bool lastFlipX = isFlipHorizontally;
    bool lastFlipY = isFlipVertically;
    _fastAnimation?.onRemove();
    _fastAnimation = AnimatedObjectOnce(
      position: position + _fastAnimationOffset,
      size: size ?? this.size,
      animation: animation,
      onStart: onStart,
      onFinish: () {
        onFinish?.call();
        _fastAnimation?.onRemove();
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

    if (gameRef != null) {
      _fastAnimation?.gameRef = gameRef!;
    }
    await _fastAnimation?.onLoad();
  }

  /// Method used to register new animation in others
  Future<void> addOtherAnimation(
    String key,
    FutureOr<SpriteAnimation> animation,
  ) async {
    others[key] = await animation;
  }

  void render(Canvas canvas, Paint paint) {
    if (_fastAnimation != null) {
      _fastAnimation?.render(canvas);
    } else {
      _current?.getSprite().render(
            canvas,
            position: position,
            size: size,
            overridePaint: paint,
          );
    }
  }

  void update(
    double dt,
    Vector2 position,
    Vector2 size,
  ) {
    this.position = position;
    this.size = size;
    if (_playing) {
      _fastAnimation?.position = position;
      if (_fastAnimationOffset != _zero) {
        _fastAnimation?.position += _fastAnimationOffset;
      }
      _fastAnimation?.update(dt);
      _current?.update(dt);
    }
  }

  void changeLastAnimation(SimpleAnimationEnum lastAnimation) {
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
          _current = runDownLeft;
        } else if (beforeLastPlayedAnimation == SimpleAnimationEnum.runUp) {
          _current = runUpLeft;
        } else {
          if (runLeft != null) {
            _current = runLeft;
          } else if (enabledFlipX) {
            isFlipHorizontally = true;
            _current = runRight;
          }
        }
      } else {
        if (runLeft != null) {
          _current = runLeft;
        } else if (enabledFlipX) {
          isFlipHorizontally = true;
          _current = runRight;
        }
      }
      changeLastAnimation(SimpleAnimationEnum.runLeft);
    } else {
      if (runLeft != null) {
        _current = runLeft;
      } else if (enabledFlipX) {
        isFlipHorizontally = true;
        _current = runRight;
      }
    }
  }

  void _runRight() {
    if (eightDirection) {
      if (lastPlayedAnimation == SimpleAnimationEnum.runUpRight ||
          lastPlayedAnimation == SimpleAnimationEnum.runDownRight) {
        if (beforeLastPlayedAnimation == SimpleAnimationEnum.runDown) {
          _current = runDownRight;
        } else if (beforeLastPlayedAnimation == SimpleAnimationEnum.runUp) {
          _current = runUpRight;
        } else {
          _current = runRight;
        }
      } else {
        _current = runRight;
      }
      changeLastAnimation(SimpleAnimationEnum.runRight);
    } else {
      _current = runRight;
    }
  }

  void _idleLeft() {
    if (idleLeft != null) {
      _current = idleLeft;
    } else if (enabledFlipX) {
      isFlipHorizontally = true;
      _current = idleRight;
    }
  }
}
