import 'dart:async';
import 'dart:ui';

import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/objects/animated_object_once.dart';
import 'package:bonfire/util/extensions/extensions.dart';
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
  Vector2 animationOffset = Vector2.zero();
  Vector2? animationSize;
  AnimatedObjectOnce? _fastAnimation;
  Vector2 _fastAnimOffset = Vector2.zero();

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (isVisible) {
      if (_fastAnimation != null) {
        _fastAnimation?.render(canvas);
      } else {
        animation?.getSprite().renderWithOpacity(
              canvas,
              position + animationOffset,
              animationSize ?? size,
              opacity: opacity,
            );
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (this.isVisible) {
      _fastAnimation?.position = position + _fastAnimOffset;
      _fastAnimation?.opacity = opacity;
      _fastAnimation?.isFlipHorizontal = isFlipHorizontal;
      _fastAnimation?.isFlipVertical = isFlipVertical;
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
    _fastAnimOffset = offset ?? Vector2.zero();
    final anim = AnimatedObjectOnce(
      position: position + _fastAnimOffset,
      size: size ?? this.size,
      animation: animation,
      onStart: onStart,
      onFinish: () {
        onFinish?.call();
        _fastAnimation = null;
      },
    )..gameRef = gameRef;
    await anim.onLoad();
    _fastAnimation = anim;
  }
}
