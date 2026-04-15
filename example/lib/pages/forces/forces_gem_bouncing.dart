import 'package:bonfire/bonfire.dart';
import 'package:example/pages/mini_games/platform/platform_spritesheet.dart';

class ForcesGemBouncing extends GameDecoration
    with Movement, Forces, SimpleCollision, SimpleElasticCollision {
  ForcesGemBouncing({
    required Vector2 position,
  }) : super.withAnimation(
          animation: PlatformSpritesheet.gem,
          position: position,
          size: Vector2(15, 13),
        ) {
    enableEarthGravity();
    setupElasticCollision(bounciness: 4);
  }

  @override
  Future<void> onLoad() {
    add(CircleHitbox(radius: size.x / 2));
    return super.onLoad();
  }
}
