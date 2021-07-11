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
  void moveUp(double speed, {VoidCallback? onCollision}) {
    if (animation.runUp != null) {
      animation.play(SimpleAnimationEnum.runUp);
    } else {
      if (lastDirectionHorizontal == Direction.left) {
        animation.play(SimpleAnimationEnum.runLeft);
      } else {
        animation.play(SimpleAnimationEnum.runRight);
      }
    }
    lastDirection = Direction.up;
    super.moveUp(speed, onCollision: onCollision);
  }

  @override
  void moveRight(double speed, {VoidCallback? onCollision}) {
    animation.play(SimpleAnimationEnum.runRight);
    lastDirection = Direction.right;
    lastDirectionHorizontal = Direction.right;
    super.moveRight(speed, onCollision: onCollision);
  }

  @override
  void moveDown(double speed, {VoidCallback? onCollision}) {
    if (animation.runDown != null) {
      animation.play(SimpleAnimationEnum.runDown);
    } else {
      if (lastDirectionHorizontal == Direction.left) {
        animation.play(SimpleAnimationEnum.runLeft);
      } else {
        animation.play(SimpleAnimationEnum.runRight);
      }
    }
    lastDirection = Direction.down;
    super.moveDown(speed, onCollision: onCollision);
  }

  @override
  void moveLeft(double speed, {VoidCallback? onCollision}) {
    animation.play(SimpleAnimationEnum.runLeft);
    lastDirection = Direction.left;
    lastDirectionHorizontal = Direction.left;
    super.moveLeft(speed, onCollision: onCollision);
  }

  @override
  void moveUpLeft(double speedX, double speedY, {VoidCallback? onCollision}) {
    if (animation.runUpLeft != null) {
      animation.play(SimpleAnimationEnum.runUpLeft);
    } else {
      animation.play(SimpleAnimationEnum.runLeft);
    }
    lastDirection = Direction.upLeft;
    lastDirectionHorizontal = Direction.left;
    super.moveUp(speedY, onCollision: onCollision);
    super.moveLeft(speedX, onCollision: onCollision);
  }

  @override
  void moveUpRight(double speedX, double speedY, {VoidCallback? onCollision}) {
    if (animation.runUpRight != null) {
      animation.play(SimpleAnimationEnum.runUpRight);
    } else {
      animation.play(SimpleAnimationEnum.runRight);
    }
    lastDirection = Direction.upRight;
    lastDirectionHorizontal = Direction.right;
    super.moveUp(speedY, onCollision: onCollision);
    super.moveRight(speedX, onCollision: onCollision);
  }

  @override
  void moveDownRight(double speedX, double speedY,
      {VoidCallback? onCollision}) {
    if (animation.runDownRight != null) {
      animation.play(SimpleAnimationEnum.runDownRight);
    } else {
      animation.play(SimpleAnimationEnum.runRight);
    }
    lastDirection = Direction.downRight;
    lastDirectionHorizontal = Direction.right;
    super.moveDown(speedY, onCollision: onCollision);
    super.moveRight(speedX, onCollision: onCollision);
  }

  @override
  void moveDownLeft(double speedX, double speedY, {VoidCallback? onCollision}) {
    if (animation.runDownLeft != null) {
      animation.play(SimpleAnimationEnum.runDownLeft);
    } else {
      animation.play(SimpleAnimationEnum.runLeft);
    }
    lastDirection = Direction.downLeft;
    lastDirectionHorizontal = Direction.left;
    super.moveDown(speedY, onCollision: onCollision);
    super.moveLeft(speedX, onCollision: onCollision);
  }

  @override
  void idle() {
    switch (lastDirection) {
      case Direction.left:
        animation.play(SimpleAnimationEnum.idleLeft);
        break;
      case Direction.right:
        animation.play(SimpleAnimationEnum.idleRight);
        break;
      case Direction.up:
        if (animation.idleUp != null) {
          animation.play(SimpleAnimationEnum.idleUp);
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
          animation.play(SimpleAnimationEnum.idleDown);
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
          animation.play(SimpleAnimationEnum.idleDownLeft);
        } else {
          animation.play(SimpleAnimationEnum.idleLeft);
        }
        break;
      case Direction.downRight:
        if (animation.idleDownRight != null) {
          animation.play(SimpleAnimationEnum.idleDownRight);
        } else {
          animation.play(SimpleAnimationEnum.idleRight);
        }
        break;
    }
    super.idle();
  }

  @override
  Future<void> onLoad() async {
    await animation.onLoad();
    idle();
  }
}
