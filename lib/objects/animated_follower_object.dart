import 'dart:async';

import 'package:bonfire/bonfire.dart';

class AnimatedFollowerObject extends GameComponent
    with Follower, UseSpriteAnimation, UseAssetsLoader {
  final bool loopAnimation;
  final bool useTargetPriority;
  final int? objectPriority;

  AnimatedFollowerObject({
    required FutureOr<SpriteAnimation> animation,
    required Vector2 size,
    GameComponent? target,
    Vector2? positionFromTarget,
    this.loopAnimation = false,
    this.useTargetPriority = true,
    this.objectPriority,
  }) {
    this.size = size;
    setupFollower(target: target, offset: positionFromTarget);
    loader?.add(AssetToLoad(animation, (value) => this.animation = value));
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!loopAnimation && animation?.isLastFrame == true) {
      removeFromParent();
    }
  }

  @override
  int get priority {
    if (followerTarget != null && useTargetPriority) {
      return followerTarget!.priority;
    } else {
      return objectPriority ?? super.priority;
    }
  }
}
