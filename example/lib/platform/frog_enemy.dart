import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:example/platform/fox_player.dart';
import 'package:example/platform/platform_spritesheet.dart';

class FrogEnemy extends PlatformEnemy with HandleForces {
  late ShapeHitbox _shapeHitbox;
  FrogEnemy({
    required Vector2 position,
  }) : super(
          position: position,
          size: Vector2(35, 32),
          speed: 50,
          animation: PlatformAnimations(
            idleRight: PlatformSpritesheet.frogIdleRight,
            runRight: PlatformSpritesheet.frogIdleRight,
            jump: PlatformJumpAnimations(
              jumpUpRight: PlatformSpritesheet.frogJumpUp,
              jumpDownRight: PlatformSpritesheet.frogJumpDown,
            ),
            others: {
              'action': PlatformSpritesheet.frogActionRight,
            },
          ),
        );

  @override
  bool onBlockMovement(Set<Vector2> intersectionPoints, GameComponent other) {
    if (other is FoxPlayer && !isDead) {
      if (other.bottom < _shapeHitbox.absolutePosition.y + 5) {
        other.jump(speed: 150);
        die();
      } else {
        other.die();
      }
    }
    return super.onBlockMovement(intersectionPoints, other);
  }

  @override
  void die() {
    super.die();
    animation?.playOnce(
      PlatformSpritesheet.enemyExplosion,
      runToTheEnd: true,
      onFinish: removeFromParent,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (checkInterval('jump', 5000, dt) && !isDead) {
      animation?.playOnce(
        PlatformSpritesheet.frogActionRight,
        flipX: lastDirectionHorizontal == Direction.left,
        onFinish: () async {
          await Future.delayed(const Duration(seconds: 2));
          jump(speed: 200);
          Random().nextBool() ? moveRight() : moveLeft();
        },
      );
    }
    if (!jumping) {
      stopMove(isY: false);
    }
  }

  @override
  Future<void> onLoad() {
    add(
      _shapeHitbox = RectangleHitbox(
        size: size / 2,
        position: Vector2(size.x / 4, size.y / 2),
        isSolid: true,
      ),
    );
    return super.onLoad();
  }
}
