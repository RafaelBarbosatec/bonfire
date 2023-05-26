import 'package:bonfire/bonfire.dart';

class PlatformPlayer extends SimplePlayer with BlockMovementCollision {
  bool jumping = false;
  final int countJumps;
  int _currentJumps = 0;

  PlatformPlayer({
    required super.position,
    required super.size,
    required PlatformAnimations animation,
    Direction initDirection = Direction.right,
    double speed = 150,
    double life = 100,
    this.countJumps = 1,
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
            },
          ),
        );

  void jump({double? speed}) {
    if (!jumping || _currentJumps < countJumps) {
      _currentJumps++;
      moveUp(speed: speed);
      jumping = true;
    }
  }

  @override
  bool onBlockMovement(Set<Vector2> intersectionPoints, GameComponent other) {
    if (jumping && lastDirectionVertical != Direction.up) {
      if (other.absoluteCenter.y > absoluteCenter.y) {
        _currentJumps = 0;
        jumping = false;
      }
    }

    return super.onBlockMovement(intersectionPoints, other);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!jumping) {
      jumping = lastDisplacement.y.abs() > speed * dt;
    }
    if (jumping) {
      _setJumpAnimation();
    } else {
      _currentJumps = 0;
    }
  }

  @override
  void onPlayRunDownAnimation() {
    if (lastDirectionHorizontal == Direction.left) {
      animation?.play(SimpleAnimationEnum.idleLeft);
    } else {
      animation?.play(SimpleAnimationEnum.idleRight);
    }
  }

  void _setJumpAnimation() {
    if (lastDirectionVertical == Direction.up) {
      if (lastDirectionHorizontal == Direction.left) {
        if (animation?.containOther(JumpAnimationsEnum.jumpUpLeft.name) ==
            true) {
          animation?.playOther(JumpAnimationsEnum.jumpUpLeft.name);
        } else {
          animation?.playOther(
            JumpAnimationsEnum.jumpUpRight.name,
            flipX: true,
          );
        }
      } else {
        animation?.playOther(JumpAnimationsEnum.jumpUpRight.name);
      }
    } else {
      if (lastDirectionHorizontal == Direction.left) {
        if (animation?.containOther(JumpAnimationsEnum.jumpDownLeft.name) ==
            true) {
          animation?.playOther(JumpAnimationsEnum.jumpDownLeft.name);
        } else {
          animation?.playOther(
            JumpAnimationsEnum.jumpDownRight.name,
            flipX: true,
          );
        }
      } else {
        animation?.playOther(JumpAnimationsEnum.jumpDownRight.name);
      }
    }
  }
}
