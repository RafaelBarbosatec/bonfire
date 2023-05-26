import 'dart:async';

import 'package:bonfire/bonfire.dart';

class PlatformJumpAnimations {
  final FutureOr<SpriteAnimation> jumpUpRight;
  final FutureOr<SpriteAnimation>? jumpUpLeft;
  final FutureOr<SpriteAnimation> jumpDownRight;
  final FutureOr<SpriteAnimation>? jumpDownLeft;

  PlatformJumpAnimations({
    required this.jumpUpRight,
    required this.jumpDownRight,
    this.jumpUpLeft,
    this.jumpDownLeft,
  });
}

class PlatformAnimations {
  final FutureOr<SpriteAnimation> idleRight;
  final FutureOr<SpriteAnimation> runRight;
  final FutureOr<SpriteAnimation>? idleLeft;
  final FutureOr<SpriteAnimation>? runLeft;
  final PlatformJumpAnimations? jump;

  PlatformAnimations({
    required this.idleRight,
    required this.runRight,
    this.idleLeft,
    this.runLeft,
    this.jump,
  });
}

enum JumpAnimationsEnum {
  jumpUpRight,
  jumpUpLeft,
  jumpDownRight,
  jumpDownLeft,
}

class PlatformPlayer extends SimplePlayer with BlockMovementCollision {
  bool jamping = false;
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
    if (!jamping || _currentJumps < countJumps) {
      _currentJumps++;
      moveUp(speed: speed);
      jamping = true;
    }
  }

  @override
  bool onBlockMovement(Set<Vector2> intersectionPoints, GameComponent other) {
    if (jamping && lastDirectionVertical != Direction.up) {
      if (other.absoluteCenter.y > absoluteCenter.y) {
        _currentJumps = 0;
        jamping = false;
      }
    }

    return super.onBlockMovement(intersectionPoints, other);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!jamping) {
      jamping = lastDisplacement.y.abs() > speed * dt;
    }
    if (jamping) {
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
