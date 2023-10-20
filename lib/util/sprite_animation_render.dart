// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:ui';

import 'package:bonfire/bonfire.dart';

class SpriteAnimationRender {
  SpriteAnimationTicker? _animationTicker;
  SpriteAnimation? _animation;
  final VoidCallback? onFinish;
  final VoidCallback? onStart;
  final Vector2? position;
  final bool loop;
  Vector2? size;

  set animation(SpriteAnimation? animation) {
    _animation = animation;
    _animation?.loop = loop;
    _animationTicker = animation?.createTicker();
    _animationTicker?.onStart = onStart;
    _animationTicker?.onComplete = onFinish;
  }

  SpriteAnimationRender({
    SpriteAnimation? animation,
    this.size,
    this.position,
    this.onFinish,
    this.onStart,
    this.loop = true,
    bool autoPlay = true,
  }) : _animation = animation {
    _animation?.loop = loop;
    _animationTicker = animation?.createTicker();
    _animationTicker?.onStart = onStart;
    _animationTicker?.onComplete = onFinish;
    _animationTicker?.paused = !autoPlay;
  }

  void render(
    Canvas canvas, {
    Paint? overridePaint,
    Vector2? size,
    Vector2? position,
  }) {
    _animationTicker?.getSprite().render(
          canvas,
          size: size ?? this.size,
          overridePaint: overridePaint,
          position: position ?? this.position,
        );
  }

  void update(double dt) {
    _animationTicker?.update(dt);
  }

  bool get isLastFrame => _animationTicker?.isLastFrame ?? false;
  int get currentIndex => _animationTicker?.currentIndex ?? 0;
  bool get isPaused => _animationTicker?.isPaused ?? false;

  void pause() {
    _animationTicker?.paused = true;
  }

  void play() {
    _animationTicker?.paused = false;
  }
}
