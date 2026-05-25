import 'package:bonfire/bonfire.dart';
import 'package:bonfire/mixins/direction_animation.dart';

enum JumpAnimationsEnum {
  jumpUpRight,
  jumpUpLeft,
  jumpDownRight,
  jumpDownLeft,
}

/// Mixin used to adds animations in a Jumper.
mixin JumperAnimation on Jumper, DirectionAnimation {
  @override
  void onMount() {
    super.onMount();
    jumper.onJumpStateChangedListener(_onJumpStateChanged);
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

  @override
  void onPlayRunDownAnimation() {
    if (jumper.isJumping) {
      if (hDirection.isLeftSide) {
        _jumpDownLeft();
      } else {
        animation?.playOther(
          JumpAnimationsEnum.jumpDownRight,
          flipX: false,
        );
      }
    }
  }

  @override
  void onPlayRunDownRightAnimation() {
    if (jumper.isJumping) {
      animation?.playOther(JumpAnimationsEnum.jumpDownRight, flipX: false);
    } else {
      super.onPlayRunDownRightAnimation();
    }
  }

  @override
  void onPlayRunDownLeftAnimation() {
    if (jumper.isJumping) {
      _jumpDownLeft();
    } else {
      super.onPlayRunDownLeftAnimation();
    }
  }

  @override
  void onPlayRunUpLeftAnimation() {
    if (jumper.isJumping) {
      _playJumpUpLeft();
    } else {
      super.onPlayRunUpLeftAnimation();
    }
  }

  @override
  void onPlayRunLeftAnimation() {
    if (jumper.isJumping) {
      _playJumpUpLeft();
    } else {
      super.onPlayRunLeftAnimation();
    }
  }

  @override
  void onPlayRunRightAnimation() {
    if (jumper.isJumping) {
      animation?.playOther(JumpAnimationsEnum.jumpUpRight, flipX: false);
    } else {
      super.onPlayRunRightAnimation();
    }
  }

  @override
  void onPlayRunUpRightAnimation() {
    if (jumper.isJumping) {
      animation?.playOther(JumpAnimationsEnum.jumpUpRight, flipX: false);
    } else {
      super.onPlayRunUpRightAnimation();
    }
  }

  @override
  void onPlayRunUpAnimation() {
    if (jumper.isJumping) {
      if (hDirection.isLeftSide) {
        _playJumpUpLeft();
      } else {
        animation?.playOther(JumpAnimationsEnum.jumpUpRight, flipX: false);
      }
    } else {
      super.onPlayRunUpAnimation();
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

  @override
  void idle() {
    if (!jumper.isJumping) {
      super.idle();
    }
  }
}
