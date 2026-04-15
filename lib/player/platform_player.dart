import 'package:bonfire/bonfire.dart';

class PlatformPlayer extends SimplePlayer
    with BlockMovementCollision, Jumper, JumperAnimation {
  PlatformPlayer({
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

  @override
  void onJoystickChangeDirectional(JoystickDirectionalEvent event) {
    var newDirectional = JoystickMoveDirectional.IDLE;

    if (event.directional.isRight) {
      newDirectional = JoystickMoveDirectional.MOVE_RIGHT;
    } else if (event.directional.isLeft) {
      newDirectional = JoystickMoveDirectional.MOVE_LEFT;
    }

    super.onJoystickChangeDirectional(
      event.copyWith(
        directional: newDirectional,
      ),
    );
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
