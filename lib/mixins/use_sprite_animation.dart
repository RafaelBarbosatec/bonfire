import 'dart:async';
import 'dart:ui';

import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/util/sprite_animation_render.dart';
import 'package:flame/components.dart';

///
/// Created by
///
/// ─▄▀─▄▀
/// ──▀──▀
/// █▀▀▀▀▀█▄
/// █░░░░░█─█
/// ▀▄▄▄▄▄▀▀
///
/// Rafaelbarbosatec
/// on 04/02/22
mixin UseSpriteAnimation on GameComponent {
  Paint? _strockePaint;
  double _strokeWidth = 0;
  Vector2 _strokeSize = Vector2.zero();
  Vector2 _strokePosition = Vector2.zero();
  Vector2? spriteAnimationOffset;

  /// set Animation that will be drawn on the screen.
  void setAnimation(
    SpriteAnimation? animation, {
    Vector2? size,
    bool loop = true,
    bool autoPlay = true,
    VoidCallback? onFinish,
    VoidCallback? onStart,
  }) {
    _animationRender = SpriteAnimationRender(
      animation: animation,
      size: size ?? this.size,
      loop: loop,
      onFinish: onFinish,
      onStart: onStart,
      autoPlay: autoPlay,
    );
  }

  SpriteAnimationRender? _fastAnimation;
  SpriteAnimationRender? _animationRender;

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (!isRemoving && isVisible) {
      if (_fastAnimation != null) {
        if (_strockePaint != null) {
          _fastAnimation?.render(
            canvas,
            position:
                _strokePosition + (spriteAnimationOffset ?? Vector2.zero()),
            size: _strokeSize,
            overridePaint: _strockePaint,
          );
        }
        _fastAnimation?.render(canvas, overridePaint: paint);
      } else {
        if (_strockePaint != null) {
          _animationRender?.render(
            canvas,
            position:
                _strokePosition + (spriteAnimationOffset ?? Vector2.zero()),
            size: _strokeSize,
            overridePaint: _strockePaint,
          );
        }
        _animationRender?.render(
          canvas,
          position: spriteAnimationOffset,
          overridePaint: paint,
          size: size,
        );
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_fastAnimation != null) {
      _fastAnimation?.update(dt);
    } else {
      _animationRender?.update(dt);
    }
    if (_strokeSize.isZero()) {
      _strokeSize = Vector2(
        size.x + _strokeWidth * 2,
        size.y + _strokeWidth * 2,
      );
    }
  }

  /// Method used to play animation once time
  Future<void> playSpriteAnimationOnce(
    FutureOr<SpriteAnimation> animation, {
    Vector2? size,
    Vector2? offset,
    VoidCallback? onFinish,
    VoidCallback? onStart,
    bool loop = false,
  }) async {
    final completer = Completer();
    _fastAnimation = SpriteAnimationRender(
      position: offset,
      size: size ?? this.size,
      animation: await animation,
      loop: loop,
      onFinish: () {
        _fastAnimation = null;
        onFinish?.call();
        completer.complete();
      },
      onStart: onStart,
    );
    return completer.future;
  }

  void pauseAnimation() {
    _animationRender?.pause();
  }

  void playAnimation() {
    _animationRender?.play();
  }

  bool get isAnimationLastFrame => _animationRender?.isLastFrame ?? false;
  int get animationCurrentIndex => _animationRender?.currentIndex ?? 0;
  bool get isPaused => _animationRender?.isPaused ?? false;

  void showAnimationStroke(Color color, double width, {Vector2? offset}) {
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

  void hideAnimationStroke() {
    _strockePaint = null;
  }
}
