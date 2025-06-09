import 'dart:async';

import 'package:bonfire/bonfire.dart';

/// Mixin responsible for adding animations to movements
mixin DirectionAnimation on Movement {
  SimpleDirectionAnimation? animation;

  Vector2 get animationScale => size.clone()..divide(animation!.animationSize);

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (!isRemoving && isVisible) {
      animation?.render(canvas, paint);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _updateAnimation();
    animation?.update(dt, size);
  }

  void _updateAnimation() {
    if (isIdle) {
      return;
    }
    switch (lastDirection) {
      case Direction.left:
        onPlayRunLeftAnimation();
        break;
      case Direction.right:
        onPlayRunRightAnimation();
        break;
      case Direction.up:
        onPlayRunUpAnimation();
        break;
      case Direction.down:
        onPlayRunDownAnimation();
        break;
      case Direction.upLeft:
        onPlayRunUpLeftAnimation();
        break;
      case Direction.upRight:
        onPlayRunUpRightAnimation();
        break;
      case Direction.downLeft:
        onPlayRunDownLeftAnimation();
        break;
      case Direction.downRight:
        onPlayRunDownRightAnimation();
        break;
    }
  }

  @override
  void idle() {
    super.idle();
    _playIdleAnimation();
  }

  void _playIdleAnimation() {
    switch (lastDirection) {
      case Direction.left:
        onPlayIdleLeftAnimation();
        break;
      case Direction.right:
        onPlayIdleRightAnimation();
        break;
      case Direction.up:
        onPlayIdleUpAnimation();
        break;
      case Direction.down:
        onPlayIdleDownAnimation();
        break;
      case Direction.upLeft:
        onPlayIdleUpLeftAnimation();
        break;
      case Direction.upRight:
        onPlayIdleUpRightAnimation();
        break;
      case Direction.downLeft:
        onPlayIdleDownLeftAnimation();
        break;
      case Direction.downRight:
        onPlayIdleDownRightAnimation();
        break;
    }
  }

  @override
  Future<void> onLoad() async {
    await animation?.onLoad(gameRef);
    return super.onLoad();
  }

  @override
  void onMount() {
    super.onMount();
    _playIdleAnimation();
  }

  Future<void> replaceAnimation(
    SimpleDirectionAnimation newAnimation, {
    bool doIdle = false,
  }) async {
    await newAnimation.onLoad(gameRef);
    animation = newAnimation;
    if (doIdle) {
      idle();
    }
  }

  void onPlayRunDownAnimation() {
    if (animation?.canRunDown == true) {
      animation?.play(SimpleAnimationEnum.runDown);
    } else {
      if (lastDirectionHorizontal == Direction.left) {
        animation?.play(SimpleAnimationEnum.runLeft);
      } else {
        animation?.play(SimpleAnimationEnum.runRight);
      }
    }
  }

  void onPlayRunUpAnimation() {
    if (animation?.canRunUp == true) {
      animation?.play(SimpleAnimationEnum.runUp);
    } else {
      if (lastDirectionHorizontal == Direction.left) {
        animation?.play(SimpleAnimationEnum.runLeft);
      } else {
        animation?.play(SimpleAnimationEnum.runRight);
      }
    }
  }

  void onPlayRunUpLeftAnimation() {
    if (animation?.canRunUpLeft == true) {
      animation?.play(SimpleAnimationEnum.runUpLeft);
    } else {
      animation?.play(SimpleAnimationEnum.runLeft);
    }
  }

  void onPlayRunUpRightAnimation() {
    if (animation?.canRunUpRight == true) {
      animation?.play(SimpleAnimationEnum.runUpRight);
    } else {
      animation?.play(SimpleAnimationEnum.runRight);
    }
  }

  void onPlayRunDownLeftAnimation() {
    if (animation?.canRunDownLeft == true) {
      animation?.play(SimpleAnimationEnum.runDownLeft);
    } else {
      animation?.play(SimpleAnimationEnum.runLeft);
    }
  }

  void onPlayRunDownRightAnimation() {
    if (animation?.canRunDownRight == true) {
      animation?.play(SimpleAnimationEnum.runDownRight);
    } else {
      animation?.play(SimpleAnimationEnum.runRight);
    }
  }

  void onPlayRunLeftAnimation() {
    animation?.play(SimpleAnimationEnum.runLeft);
  }

  void onPlayRunRightAnimation() {
    animation?.play(SimpleAnimationEnum.runRight);
  }

  void onPlayIdleUpAnimation() {
    if (animation?.canIdleUp == true) {
      animation?.play(SimpleAnimationEnum.idleUp);
    } else {
      if (lastDirectionHorizontal == Direction.left) {
        animation?.play(SimpleAnimationEnum.idleLeft);
      } else {
        animation?.play(SimpleAnimationEnum.idleRight);
      }
    }
  }

  void onPlayIdleDownAnimation() {
    if (animation?.canIdleDown == true) {
      animation?.play(SimpleAnimationEnum.idleDown);
    } else {
      if (lastDirectionHorizontal == Direction.left) {
        animation?.play(SimpleAnimationEnum.idleLeft);
      } else {
        animation?.play(SimpleAnimationEnum.idleRight);
      }
    }
  }

  void onPlayIdleUpLeftAnimation() {
    animation?.play(SimpleAnimationEnum.idleUpLeft);
  }

  void onPlayIdleUpRightAnimation() {
    animation?.play(SimpleAnimationEnum.idleUpRight);
  }

  void onPlayIdleDownLeftAnimation() {
    animation?.play(SimpleAnimationEnum.idleDownLeft);
  }

  void onPlayIdleDownRightAnimation() {
    animation?.play(SimpleAnimationEnum.idleDownRight);
  }

  void onPlayIdleLeftAnimation() {
    animation?.play(SimpleAnimationEnum.idleLeft);
  }

  void onPlayIdleRightAnimation() {
    animation?.play(SimpleAnimationEnum.idleRight);
  }
}
