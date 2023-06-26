import 'package:bonfire/bonfire.dart';

class FollowerGameObject extends GameObject with Follower {
  FollowerGameObject({
    required GameComponent target,
    required super.size,
    required super.sprite,
    Vector2? offset,
    super.objectPriority,
  }) : super(position: target.position + (offset ?? Vector2.zero())) {
    setupFollower(target: target, offset: offset);
  }
}
