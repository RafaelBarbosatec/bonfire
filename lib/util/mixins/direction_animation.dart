import 'dart:ui';

import 'package:bonfire/bonfire.dart';

/// Mixin responsible for adding animations to movements
mixin DirectionAnimation on Movement {
  SimpleDirectionAnimation? animation;

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (isVisible) {
      animation?.render(canvas);
    }
  }

  @override
  void update(double dt) {
    animation?.update(dt, position, size, opacity);
    super.update(dt);
  }

  @override
  bool moveUp(double speed, {bool notifyOnMove = true}) {
    if (animation?.runUp != null) {
      animation?.play(SimpleAnimationEnum.runUp);
    } else {
      if (lastDirectionHorizontal == Direction.left) {
        animation?.play(SimpleAnimationEnum.runLeft);
      } else {
        animation?.play(SimpleAnimationEnum.runRight);
      }
    }
    return super.moveUp(speed, notifyOnMove: notifyOnMove);
  }

  @override
  bool moveRight(double speed, {bool notifyOnMove = true}) {
    animation?.play(SimpleAnimationEnum.runRight);
    return super.moveRight(speed, notifyOnMove: notifyOnMove);
  }

  @override
  bool moveDown(double speed, {bool notifyOnMove = true}) {
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

    return super.moveDown(speed, notifyOnMove: notifyOnMove);
  }

  @override
  bool moveLeft(double speed, {bool notifyOnMove = true}) {
    animation?.play(SimpleAnimationEnum.runLeft);
    return super.moveLeft(speed, notifyOnMove: notifyOnMove);
  }

  @override
  bool moveUpLeft(double speedX, double speedY) {
    if (animation?.runUpLeft != null) {
      animation?.play(SimpleAnimationEnum.runUpLeft);
    } else {
      animation?.play(SimpleAnimationEnum.runLeft);
    }
    return super.moveUpLeft(speedX, speedY);
  }

  @override
  bool moveUpRight(double speedX, double speedY) {
    if (animation?.runUpRight != null) {
      animation?.play(SimpleAnimationEnum.runUpRight);
    } else {
      animation?.play(SimpleAnimationEnum.runRight);
    }
    return super.moveUpRight(speedX, speedY);
  }

  @override
  bool moveDownRight(double speedX, double speedY) {
    if (animation?.runDownRight != null) {
      animation?.play(SimpleAnimationEnum.runDownRight);
    } else {
      animation?.play(SimpleAnimationEnum.runRight);
    }
    return super.moveDownRight(speedX, speedY);
  }

  @override
  bool moveDownLeft(double speedX, double speedY) {
    if (animation?.runDownLeft != null) {
      animation?.play(SimpleAnimationEnum.runDownLeft);
    } else {
      animation?.play(SimpleAnimationEnum.runLeft);
    }
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
        if (animation?.idleUpLeft != null) {
          animation?.play(SimpleAnimationEnum.idleUpLeft);
        } else {
          animation?.play(SimpleAnimationEnum.idleLeft);
        }
        break;
      case Direction.upRight:
        if (animation?.idleUpRight != null) {
          animation?.play(SimpleAnimationEnum.idleUpRight);
        } else {
          animation?.play(SimpleAnimationEnum.idleRight);
        }
        break;
      case Direction.downLeft:
        if (animation?.idleDownLeft != null) {
          animation?.play(SimpleAnimationEnum.idleDownLeft);
        } else {
          animation?.play(SimpleAnimationEnum.idleLeft);
        }
        break;
      case Direction.downRight:
        if (animation?.idleDownRight != null) {
          animation?.play(SimpleAnimationEnum.idleDownRight);
        } else {
          animation?.play(SimpleAnimationEnum.idleRight);
        }
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
