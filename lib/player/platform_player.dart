import 'package:bonfire/bonfire.dart';

class PlatformPlayer extends SimplePlayer
    with BlockMovementCollision, Jumper, JumperAnimation {
  PlatformPlayer({
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

  @override
  Future<void> replaceAnimation(
    SimpleDirectionAnimation newAnimation, {
    bool doIdle = false,
  }) {
    throw Exception(
      'In PlatformPlayer update animation using replacePlatformAnimation',
    );
  }

  Future<void> replacePlatformAnimation(
    PlatformAnimations animation, {
    bool doIdle = false,
  }) {
    return super.replaceAnimation(
      SimpleDirectionAnimation(
        idleRight: animation.idleRight,
        runRight: animation.runRight,
        idleLeft: animation.idleLeft,
        runLeft: animation.runLeft,
        others: {
          if (animation.jump?.jumpUpRight != null)
            JumpAnimationsEnum.jumpUpRight.name: animation.jump!.jumpUpRight,
          if (animation.jump?.jumpUpLeft != null)
            JumpAnimationsEnum.jumpUpLeft.name: animation.jump!.jumpUpLeft!,
          if (animation.jump?.jumpDownRight != null)
            JumpAnimationsEnum.jumpDownRight.name:
                animation.jump!.jumpDownRight,
          if (animation.jump?.jumpDownLeft != null)
            JumpAnimationsEnum.jumpDownLeft.name: animation.jump!.jumpDownLeft!,
          ...animation.others ?? {},
        },
      ),
      doIdle: doIdle,
    );
  }
}
