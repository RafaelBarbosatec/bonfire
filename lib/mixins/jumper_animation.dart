import 'package:bonfire/bonfire.dart';

enum JumpAnimationsEnum {
  jumpUpRight,
  jumpUpLeft,
  jumpDownRight,
  jumpDownLeft,
}

/// Mixin used to adds animations in a Jumper.
mixin JumperAnimation on WithJumper, DirectionAnimation {
  @override
  void onMount() {
    super.onMount();
    jumper.onJumpStateChangedListener(_onJumpStateChanged);
    directionAnimation.onAnimationExecutionListener(
      _onDirectionAnimationExecution,
    );
  }

  void _onJumpStateChanged(JumpingStateEnum state) {
    if (state == JumpingStateEnum.idle) {
      if (hDirection.isLeftSide) {
        animation?.play(SimpleAnimationEnum.idleLeft);
      } else {
        animation?.play(SimpleAnimationEnum.idleRight);
      }
    }
  }

  DirectionAnimationMethod? _lastDirectionAnimationMethod;

  bool _onDirectionAnimationExecution(DirectionAnimationMethod method) {
    if (!jumper.isJumping) {
      return true;
    }

    if (_lastDirectionAnimationMethod == method) {
      return false;
    }

    _lastDirectionAnimationMethod = method;

    switch (method) {
      case DirectionAnimationMethod.onPlayRunDownAnimation:
        if (hDirection.isLeftSide) {
          _jumpDownLeft();
        } else {
          animation?.playOther(
            JumpAnimationsEnum.jumpDownRight,
            flipX: false,
          );
        }
        return false;
      case DirectionAnimationMethod.onPlayRunDownRightAnimation:
        animation?.playOther(JumpAnimationsEnum.jumpDownRight, flipX: false);
        return false;
      case DirectionAnimationMethod.onPlayRunDownLeftAnimation:
        _jumpDownLeft();
        return false;
      case DirectionAnimationMethod.onPlayRunUpLeftAnimation:
      case DirectionAnimationMethod.onPlayRunLeftAnimation:
        _playJumpUpLeft();
        return false;
      case DirectionAnimationMethod.onPlayRunRightAnimation:
      case DirectionAnimationMethod.onPlayRunUpRightAnimation:
        animation?.playOther(JumpAnimationsEnum.jumpUpRight, flipX: false);
        return false;
      case DirectionAnimationMethod.onPlayRunUpAnimation:
        if (hDirection.isLeftSide) {
          _playJumpUpLeft();
        } else {
          animation?.playOther(JumpAnimationsEnum.jumpUpRight, flipX: false);
        }
        return false;
      default:
        return true;
    }
  }

  void _playJumpUpLeft() {
    if (animation?.containOther(JumpAnimationsEnum.jumpUpLeft) == true) {
      animation?.playOther(JumpAnimationsEnum.jumpUpLeft);
    } else {
      animation?.playOther(
        JumpAnimationsEnum.jumpUpRight,
        flipX: true,
      );
    }
  }

  void _jumpDownLeft() {
    if (animation?.containOther(JumpAnimationsEnum.jumpDownLeft) == true) {
      animation?.playOther(JumpAnimationsEnum.jumpDownLeft);
    } else {
      animation?.playOther(
        JumpAnimationsEnum.jumpDownRight,
        flipX: true,
      );
    }
  }
}
