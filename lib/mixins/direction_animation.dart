import 'dart:ui';

import 'package:bonfire/bonfire.dart';

/// Mixin responsible for adding animations to movements
mixin DirectionAnimation on Movement {
  SimpleDirectionAnimation? animation;

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (isVisible) {
      animation?.render(canvas, paint);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isVisible) {
      _updateAnimation();
      animation?.update(dt, position, size);
    }
  }

  void _updateAnimation() {
    if (isIdle) {
      return;
    }
    switch (lastDirection) {
      case Direction.left:
        animation?.play(SimpleAnimationEnum.runLeft);
        break;
      case Direction.right:
        animation?.play(SimpleAnimationEnum.runRight);
        break;
      case Direction.up:
        if (animation?.runUp != null) {
          animation?.play(SimpleAnimationEnum.runUp);
        } else {
          if (lastDirectionHorizontal == Direction.left) {
            animation?.play(SimpleAnimationEnum.runLeft);
          } else {
            animation?.play(SimpleAnimationEnum.runRight);
          }
        }
        break;
      case Direction.down:
        executeDownAnimation();
        break;
      case Direction.upLeft:
        if (animation?.runUpLeft != null) {
          animation?.play(SimpleAnimationEnum.runUpLeft);
        } else {
          animation?.play(SimpleAnimationEnum.runLeft);
        }
        break;
      case Direction.upRight:
        if (animation?.runUpRight != null) {
          animation?.play(SimpleAnimationEnum.runUpRight);
        } else {
          animation?.play(SimpleAnimationEnum.runRight);
        }
        break;
      case Direction.downLeft:
        if (animation?.runDownLeft != null) {
          animation?.play(SimpleAnimationEnum.runDownLeft);
        } else {
          animation?.play(SimpleAnimationEnum.runLeft);
        }
        break;
      case Direction.downRight:
        if (animation?.runDownRight != null) {
          animation?.play(SimpleAnimationEnum.runDownRight);
        } else {
          animation?.play(SimpleAnimationEnum.runRight);
        }
        break;
    }
  }

  @override
  void idle() {
    super.idle();
    switch (lastDirection) {
      case Direction.left:
        animation?.play(SimpleAnimationEnum.idleLeft);
        break;
      case Direction.right:
        animation?.play(SimpleAnimationEnum.idleRight);
        break;
      case Direction.up:
        if (animation?.idleUp != null) {
          animation?.play(SimpleAnimationEnum.idleUp);
        } else {
          if (lastDirectionHorizontal == Direction.left) {
            animation?.play(SimpleAnimationEnum.idleLeft);
          } else {
            animation?.play(SimpleAnimationEnum.idleRight);
          }
        }
        break;
      case Direction.down:
        if (animation?.idleDown != null ||
            (animation?.idleUp != null && animation?.enabledFlipY == true)) {
          animation?.play(SimpleAnimationEnum.idleDown);
        } else {
          if (lastDirectionHorizontal == Direction.left) {
            animation?.play(SimpleAnimationEnum.idleLeft);
          } else {
            animation?.play(SimpleAnimationEnum.idleRight);
          }
        }
        break;
      case Direction.upLeft:
        animation?.play(SimpleAnimationEnum.idleUpLeft);
        break;
      case Direction.upRight:
        animation?.play(SimpleAnimationEnum.idleUpRight);
        break;
      case Direction.downLeft:
        animation?.play(SimpleAnimationEnum.idleDownLeft);
        break;
      case Direction.downRight:
        animation?.play(SimpleAnimationEnum.idleDownRight);
        break;
    }
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await animation?.onLoad(gameRef);
    idle();
  }

  Future<void> replaceAnimation(
    SimpleDirectionAnimation newAnimation, {
    bool doIdle = true,
  }) async {
    await newAnimation.onLoad(gameRef);
    animation = newAnimation;
    if (doIdle) {
      idle();
    }
  }

  void executeDownAnimation() {
    if (animation?.runDown != null ||
        (animation?.runUp != null && animation?.enabledFlipY == true)) {
      animation?.play(SimpleAnimationEnum.runDown);
    } else {
      if (lastDirectionHorizontal == Direction.left) {
        animation?.play(SimpleAnimationEnum.runLeft);
      } else {
        animation?.play(SimpleAnimationEnum.runRight);
      }
    }
  }
}
