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
    if (isVisible) {
      animation?.update(dt, position, size);
      isFlipHorizontally = animation?.isFlipHorizontally ?? false;
      isFlipVertically = animation?.isFlipVertically ?? false;
    }
    super.update(dt);
  }

  @override
  bool moveUp(double speed, {bool notifyOnMove = true}) {
    if (notifyOnMove) {
      if (animation?.runUp != null) {
        animation?.play(SimpleAnimationEnum.runUp);
      } else {
        if (lastDirectionHorizontal == Direction.left) {
          animation?.play(SimpleAnimationEnum.runLeft);
        } else {
          animation?.play(SimpleAnimationEnum.runRight);
        }
      }
    }

    return super.moveUp(speed, notifyOnMove: notifyOnMove);
  }

  @override
  bool moveRight(double speed, {bool notifyOnMove = true}) {
    if (notifyOnMove) {
      animation?.play(SimpleAnimationEnum.runRight);
    }
    return super.moveRight(speed, notifyOnMove: notifyOnMove);
  }

  @override
  bool moveDown(double speed, {bool notifyOnMove = true}) {
    if (notifyOnMove) {
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

    return super.moveDown(speed, notifyOnMove: notifyOnMove);
  }

  @override
  bool moveLeft(double speed, {bool notifyOnMove = true}) {
    if (notifyOnMove) {
      animation?.play(SimpleAnimationEnum.runLeft);
    }
    return super.moveLeft(speed, notifyOnMove: notifyOnMove);
  }

  @override
  bool moveUpLeft(double speedX, double speedY) {
    animation?.play(SimpleAnimationEnum.runUpLeft);
    return super.moveUpLeft(speedX, speedY);
  }

  @override
  bool moveUpRight(double speedX, double speedY) {
    animation?.play(SimpleAnimationEnum.runUpRight);
    return super.moveUpRight(speedX, speedY);
  }

  @override
  bool moveDownRight(double speedX, double speedY) {
    animation?.play(SimpleAnimationEnum.runDownRight);
    return super.moveDownRight(speedX, speedY);
  }

  @override
  bool moveDownLeft(double speedX, double speedY) {
    animation?.play(SimpleAnimationEnum.runDownLeft);
    return super.moveDownLeft(speedX, speedY);
  }

  @override
  void idle() {
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
    super.idle();
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
}
