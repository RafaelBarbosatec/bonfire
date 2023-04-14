import 'dart:async';
import 'package:bonfire/bonfire.dart';

class FollowerObject extends GameComponent
    with Follower, UseSprite, UseAssetsLoader {
  final bool useTargetPriority;
  final int? objectPriority;

  FollowerObject({
    required GameComponent target,
    required Vector2 size,
    required FutureOr<Sprite> sprite,
    Vector2? positionFromTarget,
    this.useTargetPriority = true,
    this.objectPriority,
  }) {
    this.size = size;
    setupFollower(target: target, offset: positionFromTarget);
    loader?.add(AssetToLoad(sprite, (value) => this.sprite = value));
    applyBleedingPixel(position: position, size: size);
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
