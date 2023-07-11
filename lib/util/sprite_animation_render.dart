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
  bool _playing = true;

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
    _playing = autoPlay;
    _animationTicker = animation?.createTicker();
    _animationTicker?.onStart = onStart;
    _animationTicker?.onComplete = onFinish;
  }

  void render(Canvas canvas, {Paint? overridePaint}) {
    _animationTicker?.getSprite().render(
          canvas,
          size: size,
          overridePaint: overridePaint,
          position: position,
        );
  }

  void update(double dt) {
    if (_playing) {
      _animationTicker?.update(dt);
    }
  }

  void pause() {
    _playing = false;
  }

  void play() {
    _playing = true;
  }
}
