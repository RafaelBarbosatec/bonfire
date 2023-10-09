import 'package:bonfire/bonfire.dart';

// Component with `Sprite` that follow other `GameComponent`
class FollowerGameObject extends GameObject with Follower {
  FollowerGameObject({
    required GameComponent target,
    required super.size,
    required super.sprite,
    Vector2? offset,
    super.objectPriority,
    super.lightingConfig,
    super.renderAboveComponents,
  }) : super(position: target.position + (offset ?? Vector2.zero())) {
    setupFollower(target: target, offset: offset);
  }
}
