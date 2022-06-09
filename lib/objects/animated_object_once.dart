import 'dart:async';
import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/assets_loader.dart';

class AnimatedObjectOnce extends GameComponent
    with UseSpriteAnimation, UseAssetsLoader, Lighting {
  final VoidCallback? onFinish;
  final VoidCallback? onStartAnimation;
  bool _notifyStart = false;

  AnimatedObjectOnce({
    required Vector2 position,
    required Vector2 size,
    FutureOr<SpriteAnimation>? animation,
    this.onFinish,
    this.onStartAnimation,
    double rotateRadAngle = 0,
    LightingConfig? lightingConfig,
  }) {
    loader?.add(AssetToLoad(animation, (value) {
      this.animation = value..loop = false;
    }));
    setupLighting(lightingConfig);
    this.position = position;
    this.size = size;
    this.angle = rotateRadAngle;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (animation?.done() == true) {
      onFinish?.call();
      removeFromParent();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (animation != null && !isRemoving) {
      if (animation?.currentIndex == 1 && !_notifyStart) {
        _notifyStart = true;
        onStartAnimation?.call();
      }
    }
  }
}
