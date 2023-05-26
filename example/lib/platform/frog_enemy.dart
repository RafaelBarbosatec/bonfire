import 'dart:math';

import 'package:bonfire/bonfire.dart';
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
            others: {
              'action': PlatformSpritesheet.frogActionRight,
            },
          ),
        ) {
    addForce(
      AccelerationForce2D(
        id: 'gravity',
        value: Vector2(0, 400),
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (checkInterval('jump', 5000, dt)) {
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
      RectangleHitbox(
        size: size / 2,
        position: Vector2(size.x / 4, size.y / 2),
        isSolid: true,
      ),
    );
    return super.onLoad();
  }
}
