import 'dart:async';
import 'dart:ui';

import 'package:bonfire/bonfire.dart';

class AnimatedObjectOnce extends GameComponent with UseAssetsLoader, Lighting {
  final VoidCallback? onFinish;
  final VoidCallback? onStart;
  SpriteAnimation? animation;
  bool _notifyStart = false;

  AnimatedObjectOnce({
    required Vector2 position,
    required Vector2 size,
    FutureOr<SpriteAnimation>? animation,
    this.onFinish,
    this.onStart,
    double rotateRadAngle = 0,
    LightingConfig? lightingConfig,
  }) {
    loader?.add(AssetToLoad(animation, (value) {
      this.animation = value..loop = false;
    }));
    setupLighting(lightingConfig);
    this.position = position;
    this.size = size;
    angle = rotateRadAngle;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (isVisible) {
      animation?.getSprite().render(
            canvas,
            position: position,
            size: size,
            overridePaint: paint,
          );
    }
    if (animation?.done() == true) {
      onFinish?.call();
      removeFromParent();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    animation?.update(dt);
    if (animation != null && !isRemoving) {
      if (animation?.currentIndex == 1 && !_notifyStart) {
        _notifyStart = true;
        onStart?.call();
      }
    }
  }
}
