import 'package:bonfire/bonfire.dart';
import 'package:example/pages/mini_games/platform/platform_spritesheet.dart';

class ForcesGemBouncing extends GameDecoration
    with Movement, WithForces, WithCollision, WithElasticCollision {
  ForcesGemBouncing({
    required Vector2 position,
  }) : super.withAnimation(
          animation: PlatformSpritesheet.gem,
          position: position,
          size: Vector2(15, 13),
        ) {
    elasticCollision.setup(bounciness: 2);
    forces.setup(friction: Vector2.all(0));
    forces.enableEarthGravity();
  }

  @override
  Future<void> onLoad() {
    add(CircleHitbox(radius: size.x / 2));
    return super.onLoad();
  }
}
