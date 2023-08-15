import 'dart:async';
import 'dart:ui';

import 'package:bonfire/bonfire.dart';

/// Animated component
class AnimatedGameObject extends GameComponent
    with UseAssetsLoader, Lighting, UseSpriteAnimation {
  final VoidCallback? onFinish;
  final VoidCallback? onStart;
  final bool removeOnFinish;

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
        setAnimation(
          value,
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

  void _onFinish() {
    if (removeOnFinish) {
      removeFromParent();
    }
    onFinish?.call();
  }
}
