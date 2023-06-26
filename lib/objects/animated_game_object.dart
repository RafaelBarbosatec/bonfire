import 'dart:async';
import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/sprite_animation_render.dart';

class AnimatedGameObject extends GameComponent with UseAssetsLoader, Lighting {
  final VoidCallback? onFinish;
  final VoidCallback? onStart;
  final bool removeOnFinish;
  SpriteAnimationRender? animation;

  AnimatedGameObject({
    required Vector2 position,
    required Vector2 size,
    FutureOr<SpriteAnimation>? animation,
    this.onFinish,
    this.onStart,
    this.removeOnFinish = true,
    double angle = 0,
    LightingConfig? lightingConfig,
    Anchor anchor = Anchor.topLeft,
    bool loop = true,
  }) {
    this.anchor = anchor;
    loader?.add(AssetToLoad(
      animation,
      (value) {
        this.animation = SpriteAnimationRender(
          animation: value,
          size: size,
          onFinish: _onFinish,
          onStart: onStart,
          loop: loop,
        );
      },
    ));
    setupLighting(lightingConfig);
    this.position = position;
    this.size = size;
    this.angle = angle;
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
    if (removeOnFinish) {
      removeFromParent();
    }
    onFinish?.call();
  }
}
