import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/assets_loader.dart';

class AnimatedFollowerObject extends GameComponent
    with Follower, UseSpriteAnimation, UseAssetsLoader {
  final bool loopAnimation;

  AnimatedFollowerObject({
    required FutureOr<SpriteAnimation> animation,
    required GameComponent target,
    required Vector2 size,
    Vector2? positionFromTarget,
    this.loopAnimation = false,
  }) {
    this.size = size;
    setupFollower(target, followerPositionFromTarget: positionFromTarget);
    loader?.add(AssetToLoad(animation, (value) => this.animation = value));
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!loopAnimation && animation?.isLastFrame == true) {
      removeFromParent();
    }
  }
}
