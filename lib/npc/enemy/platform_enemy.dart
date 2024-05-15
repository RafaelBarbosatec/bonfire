import 'package:bonfire/bonfire.dart';

class PlatformEnemy extends SimpleEnemy
    with BlockMovementCollision, Jumper, JumperAnimation {
  bool _canIdle = true;
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
            centerAnchor: animation.centerAnchor,
          ),
        ) {
    setupJumper(maxJump: countJumps);
  }

  @override
  void onMove(
    double speed,
    Vector2 displacement,
    Direction direction,
    double angle,
  ) {
    _canIdle = direction.isHorizontal;
    super.onMove(speed, displacement, direction, angle);
  }

  @override
  void idle() {
    print(_canIdle);
    if (_canIdle) {
      super.idle();
    }
  }
}
