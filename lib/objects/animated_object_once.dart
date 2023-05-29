import 'dart:async';
import 'dart:ui';

import 'package:bonfire/bonfire.dart';

class AnimatedObjectOnce extends GameComponent with UseAssetsLoader, Lighting {
  final VoidCallback? onFinish;
  final VoidCallback? onStart;
  SpriteAnimation? animation;

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
    loader?.add(AssetToLoad(animation, (value) {
      this.animation = value;
      this.animation?.loop = false;
      this.animation?.onStart = onStart;
      this.animation?.onComplete = _onFinish;
    }));
    setupLighting(lightingConfig);
    this.position = position;
    this.size = size;
    angle = rotateRadAngle;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (isVisible && !isRemoving) {
      animation?.getSprite().render(
            canvas,
            size: size,
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
