import 'dart:async';
import 'dart:ui';

import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/util/sprite_animation_once.dart';
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
  /// Animation that will be drawn on the screen.
  SpriteAnimation? animation;

  /// Offset of the render animation.
  Vector2 animationOffset = Vector2.zero();

  /// Size animation. if null use component size
  Vector2? animationSize;
  SpriteAnimationOnce? _fastAnimation;
  final Vector2 _fastAnimOffset = Vector2.zero();
  bool _playing = true;

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (isVisible && !isRemoving) {
      if (_fastAnimation != null) {
        _fastAnimation?.render(canvas, overridePaint: paint);
      } else {
        animation?.getSprite().render(
              canvas,
              position: animationOffset,
              size: animationSize ?? size,
              overridePaint: paint,
            );
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isVisible && _playing) {
      _fastAnimation?.update(dt);
      animation?.update(dt);
    }
  }

  /// Method used to play animation once time
  Future playSpriteAnimationOnce(
    FutureOr<SpriteAnimation> animation, {
    Vector2? size,
    Vector2? offset,
    VoidCallback? onFinish,
    VoidCallback? onStart,
  }) async {
    _fastAnimation = SpriteAnimationOnce(
      position: offset,
      size: size ?? this.size,
      animation: await animation,
      onStart: onStart,
      onFinish: () {
        _fastAnimation = null;
        onFinish?.call();
      },
    );
  }

  void pauseAnimation() => _playing = false;

  void resumeAnimation() => _playing = true;
}
