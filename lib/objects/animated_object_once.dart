import 'dart:async';
import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/sprite_animation_render.dart';

class AnimatedObjectOnce extends GameComponent with UseAssetsLoader, Lighting {
  final VoidCallback? onFinish;
  final VoidCallback? onStart;
  SpriteAnimationRender? animation;

  AnimatedObjectOnce({
    required Vector2 position,
    required Vector2 size,
    FutureOr<SpriteAnimation>? animation,
    this.onFinish,
    this.onStart,
    double rotateRadAngle = 0,
    LightingConfig? lightingConfig,
    Anchor anchor = Anchor.topLeft,
  }) {
    this.anchor = anchor;
    loader?.add(AssetToLoad(
      animation,
      (value) {
        this.animation = SpriteAnimationRender(
          animation: value,
          size: size,
          onFinish: _onFinish,
          loop: false,
        );
        onStart?.call();
      },
    ));
    setupLighting(lightingConfig);
    this.position = position;
    this.size = size;
    angle = rotateRadAngle;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (isVisible && !isRemoving) {
      animation?.render(
        canvas,
        overridePaint: paint,
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    animation?.update(dt);
  }

  void _onFinish() {
    onFinish?.call();
    removeFromParent();
  }
}
