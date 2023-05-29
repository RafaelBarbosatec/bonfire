import 'package:bonfire/bonfire.dart';
import 'package:bonfire/mixins/jumper.dart';
import 'package:bonfire/mixins/jumper_animation.dart';

class PlatformPlayer extends SimplePlayer
    with BlockMovementCollision, Jumper, JumperAnimation {
  PlatformPlayer({
    required super.position,
    required super.size,
    required PlatformAnimations animation,
    Direction initDirection = Direction.right,
    double speed = 150,
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
                JumpAnimationsEnum.jumpUpRight.name:
                    animation.jump!.jumpUpRight,
              if (animation.jump?.jumpUpLeft != null)
                JumpAnimationsEnum.jumpUpLeft.name: animation.jump!.jumpUpLeft!,
              if (animation.jump?.jumpDownRight != null)
                JumpAnimationsEnum.jumpDownRight.name:
                    animation.jump!.jumpDownRight,
              if (animation.jump?.jumpDownLeft != null)
                JumpAnimationsEnum.jumpDownLeft.name:
                    animation.jump!.jumpDownLeft!,
              ...animation.others ?? {},
            },
          ),
        ) {
    setupJumper(maxJump: countJumps);
  }
}
