import 'package:bonfire/enemy/enemy.dart';
import 'package:bonfire/util/direction.dart';
import 'package:bonfire/util/direction_animations/simple_animation_enum.dart';
import 'package:bonfire/util/direction_animations/simple_direction_animation.dart';
import 'package:flame/components.dart';
import 'package:flutter/widgets.dart';

class SimpleEnemy extends Enemy {
  SimpleDirectionAnimation animation;

  /// Variable that represents the speed of the enemy.
  final double speed;

  /// Last position the enemy was.
  late Direction lastDirection;

  /// Last horizontal position the enemy was.
  late Direction lastDirectionHorizontal;

  bool _runFastAnimation = false;

  SimpleEnemy({
    required Vector2 position,
    required double height,
    required double width,
    required this.animation,
    double life = 100,
    this.speed = 100,
    Direction initDirection = Direction.right,
  }) : super(
          position: position,
          height: height,
          width: width,
          life: life,
        ) {
    lastDirection = initDirection;
    lastDirectionHorizontal =
        initDirection == Direction.left ? Direction.left : Direction.right;
  }

  @override
  void moveUp(double speed) {
    if (_runFastAnimation) return;
    super.moveUp(speed);
  }

  @override
  void moveDown(double speed) {
    if (_runFastAnimation) return;
    if (animation.runDown != null) {
      animation.play(SimpleAnimationEnum.runBottom);
    } else {
      animation.play(lastDirectionHorizontal == Direction.right
          ? SimpleAnimationEnum.runRight
          : SimpleAnimationEnum.runLeft);
    }
    lastDirection = Direction.down;
    super.moveDown(speed);
  }

  @override
  void moveLeft(double speed) {
    if (_runFastAnimation) return;
    animation.play(SimpleAnimationEnum.runLeft);
    lastDirection = Direction.left;
    lastDirectionHorizontal = Direction.left;
    super.moveLeft(speed);
  }

  @override
  void moveRight(double speed) {
    if (_runFastAnimation) return;
    animation.play(SimpleAnimationEnum.runRight);
    lastDirection = Direction.right;
    lastDirectionHorizontal = Direction.right;
    super.moveRight(speed);
  }

  @override
  void moveUpRight(double speedX, double speedY) {
    if (_runFastAnimation) return;
    if (animation.runUpRight != null) {
      animation.play(SimpleAnimationEnum.runTopRight);
    } else {
      animation.play(SimpleAnimationEnum.runRight);
    }
    lastDirection = Direction.upRight;
    lastDirectionHorizontal = Direction.right;
    super.moveUpRight(speedX, speedY);
  }

  @override
  void moveUpLeft(double speedX, double speedY) {
    if (_runFastAnimation) return;
    if (animation.runUpLeft != null) {
      animation.play(SimpleAnimationEnum.runTopLeft);
    } else {
      animation.play(SimpleAnimationEnum.runLeft);
    }
    lastDirection = Direction.upLeft;
    lastDirectionHorizontal = Direction.left;
    super.moveUpLeft(speedX, speedY);
  }

  @override
  void moveDownRight(double speedX, double speedY) {
    if (_runFastAnimation) return;
    if (animation.runDownRight != null) {
      animation.play(SimpleAnimationEnum.runBottomRight);
    } else {
      animation.play(SimpleAnimationEnum.runRight);
    }
    lastDirection = Direction.downRight;
    lastDirectionHorizontal = Direction.right;
    super.moveDownRight(speedX, speedY);
  }

  @override
  void moveDownLeft(double speedX, double speedY) {
    if (_runFastAnimation) return;
    if (animation.runDownLeft != null) {
      animation.play(SimpleAnimationEnum.runBottomLeft);
    } else {
      animation.play(SimpleAnimationEnum.runLeft);
    }
    lastDirection = Direction.downLeft;
    lastDirectionHorizontal = Direction.left;
    super.moveDownLeft(speedX, speedY);
  }

  @override
  void idle() {
    if (isIdle) return;
    if (_runFastAnimation) return;
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
    super.idle();
  }

  @override
  void update(double dt) {
    if (isVisibleInCamera()) {
      animation.update(dt, position);
    }
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    if (isVisibleInCamera()) {
      animation.render(canvas);
    }
    super.render(canvas);
  }

  @override
  Future<void> onLoad() async {
    await animation.onLoad();
    idle();
  }
}
