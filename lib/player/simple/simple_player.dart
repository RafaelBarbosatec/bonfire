import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/direction_animations/simple_direction_animation.dart';
import 'package:flutter/widgets.dart';

class SimplePlayer extends Player {
  SimpleDirectionAnimation animation;

  late Direction lastDirection;
  Direction lastDirectionHorizontal = Direction.right;

  SimplePlayer({
    required Vector2 position,
    required this.animation,
    Direction initDirection = Direction.right,
    double speed = 150,
    double width = 32,
    double height = 32,
    double life = 100,
  }) : super(
          position: position,
          width: width,
          height: height,
          life: life,
          speed: speed,
        ) {
    lastDirection = initDirection;
    if (initDirection == Direction.left || initDirection == Direction.right) {
      lastDirectionHorizontal = initDirection;
    }
  }

  @override
  void render(Canvas canvas) {
    animation.render(canvas);
    super.render(canvas);
  }

  @override
  void update(double dt) {
    animation.update(dt, position);
    super.update(dt);
  }

  @override
  void moveTop(double speed, {VoidCallback? onCollision}) {
    if (animation.runUp != null) {
      animation.play(SimpleAnimationEnum.runTop);
    } else {
      if (lastDirectionHorizontal == Direction.left) {
        animation.play(SimpleAnimationEnum.runLeft);
      } else {
        animation.play(SimpleAnimationEnum.runRight);
      }
    }
    lastDirection = Direction.up;
    super.moveTop(speed, onCollision: onCollision);
  }

  @override
  void moveRight(double speed, {VoidCallback? onCollision}) {
    animation.play(SimpleAnimationEnum.runRight);
    lastDirection = Direction.right;
    lastDirectionHorizontal = Direction.right;
    super.moveRight(speed, onCollision: onCollision);
  }

  @override
  void moveBottom(double speed, {VoidCallback? onCollision}) {
    if (animation.runDown != null) {
      animation.play(SimpleAnimationEnum.runBottom);
    } else {
      if (lastDirectionHorizontal == Direction.left) {
        animation.play(SimpleAnimationEnum.runLeft);
      } else {
        animation.play(SimpleAnimationEnum.runRight);
      }
    }
    lastDirection = Direction.down;
    super.moveBottom(speed, onCollision: onCollision);
  }

  @override
  void moveLeft(double speed, {VoidCallback? onCollision}) {
    animation.play(SimpleAnimationEnum.runLeft);
    lastDirection = Direction.left;
    lastDirectionHorizontal = Direction.left;
    super.moveLeft(speed, onCollision: onCollision);
  }

  @override
  void moveUpLeft() {
    if (animation.runUpLeft != null) {
      animation.play(SimpleAnimationEnum.runTopLeft);
    } else {
      animation.play(SimpleAnimationEnum.runLeft);
    }
    lastDirection = Direction.upLeft;
    lastDirectionHorizontal = Direction.left;
    super.moveUpLeft();
  }

  @override
  void moveUpRight() {
    if (animation.runUpRight != null) {
      animation.play(SimpleAnimationEnum.runTopRight);
    } else {
      animation.play(SimpleAnimationEnum.runRight);
    }
    lastDirection = Direction.upRight;
    lastDirectionHorizontal = Direction.right;
    super.moveUpRight();
  }

  @override
  void moveBottomRight() {
    if (animation.runDownRight != null) {
      animation.play(SimpleAnimationEnum.runBottomRight);
    } else {
      animation.play(SimpleAnimationEnum.runRight);
    }
    lastDirection = Direction.downRight;
    lastDirectionHorizontal = Direction.right;
    super.moveBottomRight();
  }

  @override
  void moveBottomLeft() {
    if (animation.runDownLeft != null) {
      animation.play(SimpleAnimationEnum.runBottomLeft);
    } else {
      animation.play(SimpleAnimationEnum.runLeft);
    }
    lastDirection = Direction.downLeft;
    lastDirectionHorizontal = Direction.left;
    super.moveBottomLeft();
  }

  @override
  void idle() {
    if (!isIdle) {
      switch (lastDirection) {
        case Direction.left:
          animation.play(SimpleAnimationEnum.idleLeft);
          break;
        case Direction.right:
          animation.play(SimpleAnimationEnum.idleRight);
          break;
        case Direction.up:
          if (animation.idleUp != null) {
            animation.play(SimpleAnimationEnum.idleTop);
          } else {
            if (lastDirectionHorizontal == Direction.left) {
              animation.play(SimpleAnimationEnum.idleLeft);
            } else {
              animation.play(SimpleAnimationEnum.idleRight);
            }
          }
          break;
        case Direction.down:
          if (animation.idleDown != null) {
            animation.play(SimpleAnimationEnum.idleBottom);
          } else {
            if (lastDirectionHorizontal == Direction.left) {
              animation.play(SimpleAnimationEnum.idleLeft);
            } else {
              animation.play(SimpleAnimationEnum.idleRight);
            }
          }
          break;
        case Direction.upLeft:
          if (animation.idleUpLeft != null) {
            animation.play(SimpleAnimationEnum.idleTopLeft);
          } else {
            animation.play(SimpleAnimationEnum.idleLeft);
          }
          break;
        case Direction.upRight:
          if (animation.idleUpRight != null) {
            animation.play(SimpleAnimationEnum.idleTopRight);
          } else {
            animation.play(SimpleAnimationEnum.idleRight);
          }
          break;
        case Direction.downLeft:
          if (animation.idleDownLeft != null) {
            animation.play(SimpleAnimationEnum.idleBottomLeft);
          } else {
            animation.play(SimpleAnimationEnum.idleLeft);
          }
          break;
        case Direction.downRight:
          if (animation.idleDownRight != null) {
            animation.play(SimpleAnimationEnum.idleBottomRight);
          } else {
            animation.play(SimpleAnimationEnum.idleRight);
          }
          break;
      }
    }
    super.idle();
  }

  @override
  Future<void> onLoad() async {
    await animation.onLoad();
    idle();
  }
}
