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
  /// set Animation that will be drawn on the screen.
  set animation(SpriteAnimation? animation) {
    _animationRender = SpriteAnimationRender(
      animation: animation,
      size: size,
      loop: animationIsLoop,
      onFinish: () => aniamtionIsDone = true,
    );
  }

  SpriteAnimationRender? _fastAnimation;
  SpriteAnimationRender? _animationRender;

  bool aniamtionIsDone = false;
  bool animationIsLoop = true;

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (isVisible && !isRemoving) {
      if (_fastAnimation != null) {
        _fastAnimation?.render(canvas, overridePaint: paint);
      } else {
        _animationRender?.render(
          canvas,
          overridePaint: paint,
        );
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isVisible) {
      _fastAnimation?.update(dt);
      _animationRender?.update(dt);
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
    _fastAnimation = SpriteAnimationRender(
      position: offset,
      size: size ?? this.size,
      animation: await animation,
      loop: false,
      onFinish: () {
        _fastAnimation = null;
        onFinish?.call();
      },
    );
    onStart?.call();
  }
}
