import 'package:bonfire/bonfire.dart';
import 'package:flutter/services.dart';
import 'package:platform_game/util/platform_spritesheet.dart';

class FoxPlayer extends PlatformPlayer with WithForces {
  bool inTrunk = false;
  FoxPlayer({required super.position})
    : super(
        size: Vector2.all(33),
        speed: 50,
        countJumps: 2,
        animation: PlatformAnimations(
          idleRight: PlatformSpritesheet.playerIdleRight,
          runRight: PlatformSpritesheet.playerRunRight,
          jump: PlatformJumpAnimations(
            jumpUpRight: PlatformSpritesheet.playerJumpUp,
            jumpDownRight: PlatformSpritesheet.playerJumpDown,
          ),
        ),
      ) {
    collision.onBlockMovementListener(onBlockMovementListener);
  }

  @override
  void onJoystickAction(JoystickActionEvent event) {
    if (event.event == ActionEvent.DOWN &&
        (event.id == LogicalKeyboardKey.space || event.id == 1)) {
      jumper.jump();
    }
    super.onJoystickAction(event);
  }

  bool onBlockMovementListener(
    Set<Vector2> intersectionPoints,
    GameComponent other,
  ) {
    if (other is TileWithCollision && other.tileClass == 'tree_trunk') {
      if (jumper.jumpingState == JumpingStateEnum.up) {
        inTrunk = true;
      } else if (other.top > center.y) {
        inTrunk = false;
      }
      if (inTrunk) {
        return false;
      }
    }

    return true;
  }

  @override
  void onMount() {
    life.onDieListener(_onDie);
    super.onMount();
  }

  @override
  Future<void> onLoad() {
    add(
      RectangleHitbox(
        size: Vector2.all(size.x / 2),
        position: Vector2(size.x / 4, size.y - size.x / 2),
        isSolid: true,
      ),
    );
    return super.onLoad();
  }

  void _onDie() {
    removeFromParent();
  }
}
