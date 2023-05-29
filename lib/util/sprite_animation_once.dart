// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:ui';

import 'package:bonfire/bonfire.dart';

class SpriteAnimationOnce {
  SpriteAnimation animation;
  final VoidCallback? onFinish;
  final VoidCallback? onStart;
  final Vector2 size;
  final Vector2? position ;
  SpriteAnimationOnce({
    required this.animation,
    required this.size,
    this.position,
    this.onFinish,
    this.onStart,
  }) {
    animation.loop = false;
    animation.onStart = onStart;
    animation.onComplete = onFinish;
  }

  void render(Canvas canvas, {Paint? overridePaint}) {
    animation.getSprite().render(
          canvas,
          size: size,
          overridePaint: overridePaint,
          position: position,
        );
  }

  void update(double dt) {
    animation.update(dt);
  }
}
