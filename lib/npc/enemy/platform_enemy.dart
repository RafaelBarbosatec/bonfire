import 'package:bonfire/bonfire.dart';

class PlatformEnemy extends SimpleEnemy
    with BlockMovementCollision, Jumper, JumperAnimation {
  PlatformEnemy({
    required super.position,
    required super.size,
    PlatformAnimations? animation,
    super.initDirection,
    super.speed,
    super.life,
    int countJumps = 1,
  }) : super(
          animation: animation?.toSimpleDirectionAnimation(),
        ) {
    setupJumper(maxJump: countJumps);
  }
}
