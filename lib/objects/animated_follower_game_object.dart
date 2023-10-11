import 'package:bonfire/bonfire.dart';

/// Animated component that follow othe `GameComponent`
class AnimatedFollowerGameObject extends AnimatedGameObject with Follower {
  AnimatedFollowerGameObject({
    required super.animation,
    required super.size,
    required GameComponent target,
    super.lightingConfig,
    super.loop = true,
    super.onFinish,
    super.onStart,
    super.angle,
    super.removeOnFinish = true,
    Vector2? offset,
    super.objectPriority,
    super.renderAboveComponents,
  }) : super(
          position: target.position + (offset ?? Vector2.zero()),
        ) {
    setupFollower(target: target, offset: offset);
  }

  @override
  int get priority {
    return objectPriority ?? super.priority;
  }
}
