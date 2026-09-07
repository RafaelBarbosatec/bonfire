import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:platform_game/components/fox_player.dart';
import 'package:platform_game/util/platform_spritesheet.dart';

class FrogEnemy extends PlatformEnemy with WithForces {
  final IntervalTick _intervalTick = IntervalTick(4000);
  FrogEnemy({required super.position})
      : super(
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
        ) {
    collision.onBlockMovementListener(onBlockMovementListener);
    collision.onMovementBlockedListener(onMovementBlockedListener);
  }

  @override
  void onMount() {
    super.onMount();
    jumper.onJumpStateChangedListener(_onJumpStateChanged);
    life.onDieListener(_onDie);
  }

  void _onJumpStateChanged(JumpingStateEnum state) {
    if (state == JumpingStateEnum.idle) {
      velocity = velocity.copyWith(x: 0);
    }
  }

  bool onBlockMovementListener(
    Set<Vector2> intersectionPoints,
    GameComponent other,
  ) {
    if (other is FoxPlayer && isDead) return false;
    return true;
  }

  void onMovementBlockedListener(
    PositionComponent other,
    CollisionData collisionData,
  ) {
    if (other is FoxPlayer) {
      if (collisionData.direction.isUpSide) {
        if (!isDead) {
          other.jumper.jump(jumpSpeed: 100, force: true);
          life.remove(life.value);
        }
      } else {
        other.life.remove(other.life.value);
      }
    }
  }

  void _onDie() {
    forces.disable();
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
    if (isDead) return;
    if (!isVisible) return;
    if (_intervalTick.update(dt)) {
      animation?.playOnce(
        PlatformSpritesheet.frogActionRight,
        flipX: direction.isLeftSide,
        onFinish: () async {
          await Future.delayed(const Duration(seconds: 2));
          if (!isDead) {
            Random().nextBool() ? moveRight() : moveLeft();
            jumper.jump(jumpSpeed: 160);
          }
        },
      );
    }
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
    _intervalTick.updateInterval(4000 + Random().nextInt(1000));
    return super.onLoad();
  }
}
