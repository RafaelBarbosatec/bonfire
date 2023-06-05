// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:ui';

import 'package:bonfire/bonfire.dart';

class SpriteAnimationRender {
  SpriteAnimationTicker? _animationTicker;
  SpriteAnimation? _animation;
  final VoidCallback? onFinish;
  final Vector2? position;
  final bool loop;
  Vector2? size;
  bool playing;

  set animation(SpriteAnimation? animation) {
    _animation = animation;
    _animation?.loop = loop;
    _animationTicker = animation?.ticker();
  }

  SpriteAnimationRender({
    SpriteAnimation? animation,
    this.size,
    this.position,
    this.onFinish,
    this.loop = true,
    this.playing = true,
  }) : _animation = animation {
    _animation?.loop = loop;
    _animationTicker = animation?.ticker();
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
    if (playing) {
      _animationTicker?.update(dt);
    }
    if (!loop && (_animationTicker?.done() ?? false)) {
      onFinish?.call();
    }
  }
}
