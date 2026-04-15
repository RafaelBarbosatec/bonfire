import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:example/pages/mini_games/platform/fox_player.dart';
import 'package:example/pages/mini_games/platform/platform_spritesheet.dart';

class FrogEnemy extends PlatformEnemy with HandleForces {
  int _timeToWaitBeforeJump = 4000;
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
  void onBlockedMovement(
    PositionComponent other,
    CollisionData collisionData,
  ) {
    super.onBlockedMovement(other, collisionData);
    if (other is FoxPlayer) {
      if (collisionData.direction.isUpSide) {
        if (!isDead) {
          other.jump(jumpSpeed: 100, force: true);
          onDie();
        }
      } else {
        other.onDie();
      }
    }
  }

  @override
  void onDie() {
    super.onDie();
    handleForcesEnabled = false;
    velocity.setZero();
    animation?.playOnce(
      PlatformSpritesheet.enemyExplosion,
      runToTheEnd: true,
      onFinish: removeFromParent,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (checkInterval('jump', _timeToWaitBeforeJump, dt) &&
        !isDead &&
        isVisible) {
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
    _timeToWaitBeforeJump += Random().nextInt(1000);
    return super.onLoad();
  }
}
