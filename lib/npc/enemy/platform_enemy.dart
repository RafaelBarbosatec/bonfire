import 'package:bonfire/bonfire.dart';

class PlatformEnemy extends SimpleEnemy
    with BlockMovementCollision, Jumper, JumperAnimation {
  PlatformEnemy({
    required super.position,
    required super.size,
    PlatformAnimations? animation,
    Direction initDirection = Direction.right,
    double? speed,
    double life = 100,
    int countJumps = 1,
  }) : super(
          initDirection: initDirection,
          speed: speed,
          life: life,
          animation: animation?.toSimpleDirectionAnimation(),
        ) {
    setupJumper(maxJump: countJumps);
  }
}
