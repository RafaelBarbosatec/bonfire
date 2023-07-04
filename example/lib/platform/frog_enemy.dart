import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:example/platform/fox_player.dart';
import 'package:example/platform/platform_spritesheet.dart';

class FrogEnemy extends PlatformEnemy with HandleForces {
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
          ),
        );

  @override
  bool onBlockMovement(Set<Vector2> intersectionPoints, GameComponent other) {
    if (other is FoxPlayer && isDead) return false;
    return super.onBlockMovement(intersectionPoints, other);
  }

  @override
  void onBlockedMovement(PositionComponent other, Direction? direction) {
    if (other is FoxPlayer) {
      if (direction == Direction.up) {
        if (!isDead) {
          other.jump(jumpSpeed: 100, force: true);
          die();
        }
      } else {
        other.die();
      }
    }
    super.onBlockedMovement(other, direction);
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
    if (checkInterval('jump', 5000, dt) && !isDead && isVisible) {
      animation?.playOnce(
        PlatformSpritesheet.frogActionRight,
        flipX: lastDirectionHorizontal == Direction.left,
        onFinish: () async {
          await Future.delayed(const Duration(seconds: 2));
          if (!isDead) {
            jump(jumpSpeed: 160);
            Random().nextBool() ? moveRight() : moveLeft();
          }
        },
      );
    }
  }

  @override
  void onJump(JumpingStateEnum state) {
    if (state == JumpingStateEnum.idle) {
      stopMove(isY: false);
    }
    super.onJump(state);
  }

  @override
  Future<void> onLoad() {
    add(
      RectangleHitbox(
        size: size / 2,
        position: Vector2(size.x / 4, size.y / 2),
        isSolid: true,
      ),
    );
    return super.onLoad();
  }
}
