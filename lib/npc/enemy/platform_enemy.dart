import 'package:bonfire/bonfire.dart';

class PlatformEnemy extends SimpleEnemy
    with BlockMovementCollision, Jumper, JumperAnimation {
  PlatformEnemy({
    required super.position,
    required super.size,
    required PlatformAnimations animation,
    Direction initDirection = Direction.right,
    double? speed,
    double life = 100,
    int countJumps = 1,
  }) : super(
          initDirection: initDirection,
          speed: speed,
          life: life,
          animation: SimpleDirectionAnimation(
            idleRight: animation.idleRight,
            runRight: animation.runRight,
            idleLeft: animation.idleLeft,
            runLeft: animation.runLeft,
            others: {
              if (animation.jump?.jumpUpRight != null)
                JumpAnimationsEnum.jumpUpRight: animation.jump!.jumpUpRight,
              if (animation.jump?.jumpUpLeft != null)
                JumpAnimationsEnum.jumpUpLeft: animation.jump!.jumpUpLeft!,
              if (animation.jump?.jumpDownRight != null)
                JumpAnimationsEnum.jumpDownRight: animation.jump!.jumpDownRight,
              if (animation.jump?.jumpDownLeft != null)
                JumpAnimationsEnum.jumpDownLeft: animation.jump!.jumpDownLeft!,
              ...animation.others ?? {},
            },
          ),
        ) {
    setupJumper(maxJump: countJumps);
  }
}
