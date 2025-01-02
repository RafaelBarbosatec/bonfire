import 'dart:async';
import 'dart:ui';

import 'package:bonfire/bonfire.dart';

/// Animated component
class AnimatedGameObject extends GameObject with UseSpriteAnimation {
  final VoidCallback? onFinish;
  final VoidCallback? onStart;
  final bool removeOnFinish;

  AnimatedGameObject({
    required super.position,
    required super.size,
    FutureOr<SpriteAnimation>? animation,
    this.onFinish,
    this.onStart,
    this.removeOnFinish = true,
    super.angle = 0,
    super.lightingConfig,
    super.anchor = Anchor.topLeft,
    bool loop = true,
    super.objectPriority,
    super.renderAboveComponents,
  }) : super(sprite: null) {
    loader?.add(
      AssetToLoad<SpriteAnimation>(
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
      ),
    );
  }

  void _onFinish() {
    if (removeOnFinish) {
      removeFromParent();
    }
    onFinish?.call();
  }
}
