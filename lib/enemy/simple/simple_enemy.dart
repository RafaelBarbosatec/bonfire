import 'package:bonfire/enemy/enemy.dart';
import 'package:bonfire/util/direction.dart';
import 'package:bonfire/util/direction_animations/simple_animation_enum.dart';
import 'package:bonfire/util/direction_animations/simple_direction_animation.dart';
import 'package:flame/position.dart';
import 'package:flutter/widgets.dart';

class SimpleEnemy extends Enemy {
  SimpleDirectionAnimation animation;

  /// Variable that represents the speed of the enemy.
  final double speed;

  /// Last position the enemy was in.
  Direction lastDirection;

  /// Last horizontal position the enemy was in.
  Direction lastDirectionHorizontal;

  bool _isIdle = true;

  bool _runFastAnimation = false;

  SimpleEnemy({
    @required Position initPosition,
    @required double height,
    @required double width,
    @required this.animation,
    double life = 100,
    this.speed = 100,
    Direction initDirection = Direction.right,
  }) : super(
          initPosition: initPosition,
          height: height,
          width: width,
          life: life,
        ) {
    lastDirection = initDirection;
    lastDirectionHorizontal =
        initDirection == Direction.left ? Direction.left : Direction.right;
    idle();
  }

  void customMoveTop(double moveSpeed, {bool addAnimation = true}) {
    if (_runFastAnimation) return;
    this.moveTop(moveSpeed);

    if ((lastDirection != Direction.top || _isIdle) && addAnimation) {
      _isIdle = false;
      if (animation?.runTop != null) {
        animation?.play(SimpleAnimationEnum.runTop);
      } else {
        animation?.play(lastDirectionHorizontal == Direction.right
            ? SimpleAnimationEnum.runRight
            : SimpleAnimationEnum.runLeft);
      }
      lastDirection = Direction.top;
    }
  }

  void customMoveBottom(double speed, {bool addAnimation = true}) {
    if (_runFastAnimation) return;
    this.moveBottom(speed);
    if ((lastDirection != Direction.bottom || _isIdle) && addAnimation) {
      _isIdle = false;
      if (animation?.runBottom != null) {
        animation?.play(SimpleAnimationEnum.runBottom);
      } else {
        animation?.play(lastDirectionHorizontal == Direction.right
            ? SimpleAnimationEnum.runRight
            : SimpleAnimationEnum.runLeft);
      }
      lastDirection = Direction.bottom;
    }
  }

  void customMoveLeft(double speed, {bool addAnimation = true}) {
    if (_runFastAnimation) return;
    this.moveLeft(speed);
    if ((lastDirection != Direction.left || _isIdle) && addAnimation) {
      _isIdle = false;
      animation?.play(SimpleAnimationEnum.runLeft);
      lastDirection = Direction.left;
      lastDirectionHorizontal = Direction.left;
    }
  }

  void customMoveRight(double speed, {bool addAnimation = true}) {
    if (_runFastAnimation) return;
    this.moveRight(speed);
    if ((lastDirection != Direction.right || _isIdle) && addAnimation) {
      _isIdle = false;
      animation?.play(SimpleAnimationEnum.runRight);
      lastDirection = Direction.right;
      lastDirectionHorizontal = Direction.right;
    }
  }

  void customMoveTopRight(double speedX, double speedY) {
    if (_runFastAnimation) return;
    animation?.play(SimpleAnimationEnum.runTopRight);
    lastDirection = Direction.topRight;
    this.customMoveRight(speedX, addAnimation: animation?.runTopRight == null);
    this.customMoveTop(speedY, addAnimation: false);
  }

  void customMoveTopLeft(double speedX, double speedY) {
    if (_runFastAnimation) return;
    animation?.play(SimpleAnimationEnum.runTopLeft);
    lastDirection = Direction.topLeft;
    this.customMoveLeft(speedX, addAnimation: animation?.runTopLeft == null);
    this.customMoveTop(speedY, addAnimation: false);
  }

  void customMoveBottomRight(double speedX, double speedY) {
    if (_runFastAnimation) return;
    animation?.play(SimpleAnimationEnum.runBottomRight);
    lastDirection = Direction.bottomRight;
    this.customMoveRight(speedX,
        addAnimation: animation?.runBottomRight == null);
    this.customMoveBottom(speedY, addAnimation: false);
  }

  void customMoveBottomLeft(double speedX, double speedY) {
    if (_runFastAnimation) return;
    animation?.play(SimpleAnimationEnum.runBottomLeft);
    lastDirection = Direction.bottomLeft;
    this.customMoveLeft(speedX, addAnimation: animation?.runBottomLeft == null);
    this.customMoveBottom(speedY, addAnimation: false);
  }

  void idle() {
    if (_runFastAnimation) return;
    _isIdle = true;
    switch (lastDirection) {
      case Direction.left:
        animation?.play(SimpleAnimationEnum.idleLeft);
        break;
      case Direction.right:
        animation?.play(SimpleAnimationEnum.idleRight);
        break;
      case Direction.top:
        if (animation?.idleTop != null) {
          animation?.play(SimpleAnimationEnum.idleTop);
        } else {
          if (lastDirectionHorizontal == Direction.left) {
            animation?.play(SimpleAnimationEnum.idleLeft);
          } else {
            animation?.play(SimpleAnimationEnum.idleRight);
          }
        }
        break;
      case Direction.bottom:
        if (animation?.idleBottom != null) {
          animation?.play(SimpleAnimationEnum.idleBottom);
        } else {
          if (lastDirectionHorizontal == Direction.left) {
            animation?.play(SimpleAnimationEnum.idleLeft);
          } else {
            animation?.play(SimpleAnimationEnum.idleRight);
          }
        }
        break;
      case Direction.topLeft:
        if (animation?.idleTopLeft != null) {
          animation?.play(SimpleAnimationEnum.idleTopLeft);
        } else {
          animation?.play(SimpleAnimationEnum.idleLeft);
        }
        break;
      case Direction.topRight:
        if (animation?.idleTopRight != null) {
          animation?.play(SimpleAnimationEnum.idleTopRight);
        } else {
          animation?.play(SimpleAnimationEnum.idleRight);
        }
        break;
      case Direction.bottomLeft:
        if (animation?.idleBottomLeft != null) {
          animation?.play(SimpleAnimationEnum.idleBottomLeft);
        } else {
          animation?.play(SimpleAnimationEnum.idleLeft);
        }
        break;
      case Direction.bottomRight:
        if (animation?.idleBottomRight != null) {
          animation?.play(SimpleAnimationEnum.idleBottomRight);
        } else {
          animation?.play(SimpleAnimationEnum.idleRight);
        }
        break;
    }
  }

  @override
  void update(double dt) {
    if (isVisibleInCamera()) {
      animation?.update(dt, position);
    }
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    if (isVisibleInCamera()) {
      animation?.render(canvas);
    }
    super.render(canvas);
  }
}
