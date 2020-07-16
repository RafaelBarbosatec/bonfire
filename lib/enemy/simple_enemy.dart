import 'package:bonfire/bonfire.dart';
import 'package:flame/animation.dart' as FlameAnimation;
import 'package:flutter/widgets.dart';

class SimpleEnemy extends Enemy {
  /// Animation that was used when enemy stay stopped on the right.
  final FlameAnimation.Animation animIdleRight;

  /// Animation that was used when enemy stay stopped on the left.
  final FlameAnimation.Animation animIdleLeft;

  /// Animation that was used when enemy stay stopped on the top.
  final FlameAnimation.Animation animIdleTop;

  /// Animation that was used when enemy stay stopped on the bottom.
  final FlameAnimation.Animation animIdleBottom;

  /// Animation used when the enemy walks to the top.
  final FlameAnimation.Animation animRunTop;

  /// Animation used when the enemy walks to the right.
  final FlameAnimation.Animation animRunRight;

  /// Animation used when the enemy walks to the left.
  final FlameAnimation.Animation animRunLeft;

  /// Animation used when the enemy walks to the bottom.
  final FlameAnimation.Animation animRunBottom;

  final FlameAnimation.Animation animRunTopLeft;
  final FlameAnimation.Animation animRunBottomLeft;

  final FlameAnimation.Animation animRunTopRight;
  final FlameAnimation.Animation animRunBottomRight;

  final FlameAnimation.Animation animIdleTopLeft;
  final FlameAnimation.Animation animIdleBottomLeft;

  final FlameAnimation.Animation animIdleTopRight;
  final FlameAnimation.Animation animIdleBottomRight;

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
    @required this.animIdleRight,
    @required this.animIdleLeft,
    @required this.animRunRight,
    @required this.animRunLeft,
    this.animRunTopLeft,
    this.animRunBottomLeft,
    this.animRunTopRight,
    this.animRunBottomRight,
    this.animIdleTop,
    this.animIdleBottom,
    this.animRunTop,
    this.animRunBottom,
    this.animIdleTopLeft,
    this.animIdleBottomLeft,
    this.animIdleTopRight,
    this.animIdleBottomRight,
    double life = 100,
    this.speed = 100,
    Collision collision,
    Direction initDirection = Direction.right,
  }) : super(
            initPosition: initPosition,
            height: height,
            width: width,
            life: life,
            collision: collision) {
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
      animation = animRunTop ??
          (lastDirectionHorizontal == Direction.right
              ? animRunRight
              : animRunLeft);
      lastDirection = Direction.top;
    }
  }

  void customMoveBottom(double speed, {bool addAnimation = true}) {
    if (_runFastAnimation) return;
    this.moveBottom(speed);
    if ((lastDirection != Direction.bottom || _isIdle) && addAnimation) {
      _isIdle = false;
      animation = animRunBottom ??
          (lastDirectionHorizontal == Direction.right
              ? animRunRight
              : animRunLeft);
      lastDirection = Direction.bottom;
    }
  }

  void customMoveLeft(double speed, {bool addAnimation = true}) {
    if (_runFastAnimation) return;
    this.moveLeft(speed);
    if ((lastDirection != Direction.left || _isIdle) && addAnimation) {
      _isIdle = false;
      animation = animRunLeft;
      lastDirection = Direction.left;
      lastDirectionHorizontal = Direction.left;
    }
  }

  void customMoveRight(double speed, {bool addAnimation = true}) {
    if (_runFastAnimation) return;
    this.moveRight(speed);
    if ((lastDirection != Direction.right || _isIdle) && addAnimation) {
      _isIdle = false;
      animation = animRunRight;
      lastDirection = Direction.right;
      lastDirectionHorizontal = Direction.right;
    }
  }

  void customMoveTopRight(double speedX, double speedY) {
    if (_runFastAnimation) return;
    if (animRunTopRight != null) {
      animation = animRunTopRight;
    }
    lastDirection = Direction.topRight;
    this.customMoveRight(speedX, addAnimation: animRunTopRight == null);
    this.customMoveTop(speedY, addAnimation: false);
  }

  void customMoveTopLeft(double speedX, double speedY) {
    if (_runFastAnimation) return;
    if (animRunTopLeft != null) {
      animation = animRunTopLeft;
    }
    lastDirection = Direction.topLeft;
    this.customMoveLeft(speedX, addAnimation: animRunTopLeft == null);
    this.customMoveTop(speedY, addAnimation: false);
  }

  void customMoveBottomRight(double speedX, double speedY) {
    if (_runFastAnimation) return;
    if (animRunBottomRight != null) {
      animation = animRunBottomRight;
    }
    lastDirection = Direction.bottomRight;
    this.customMoveRight(speedX, addAnimation: animRunBottomRight == null);
    this.customMoveBottom(speedY, addAnimation: false);
  }

  void customMoveBottomLeft(double speedX, double speedY) {
    if (_runFastAnimation) return;
    if (animRunBottomLeft != null) {
      animation = animRunBottomLeft;
    }
    lastDirection = Direction.bottomLeft;
    this.customMoveLeft(speedX, addAnimation: animRunBottomLeft == null);
    this.customMoveBottom(speedY, addAnimation: false);
  }

  void idle() {
    if (_runFastAnimation) return;
    _isIdle = true;
    switch (lastDirection) {
      case Direction.left:
        animation = animIdleLeft;
        break;
      case Direction.right:
        animation = animIdleRight;
        break;
      case Direction.top:
        if (animIdleTop != null) {
          animation = animIdleTop;
        } else {
          if (lastDirectionHorizontal == Direction.left) {
            animation = animIdleLeft;
          } else {
            animation = animIdleRight;
          }
        }
        break;
      case Direction.bottom:
        if (animIdleBottom != null) {
          animation = animIdleBottom;
        } else {
          if (lastDirectionHorizontal == Direction.left) {
            animation = animIdleLeft;
          } else {
            animation = animIdleRight;
          }
        }
        break;
      case Direction.topLeft:
        if (animIdleTopLeft != null) {
          animation = animIdleTopLeft;
        } else {
          if (animIdleLeft != null) animation = animIdleLeft;
        }
        break;
      case Direction.topRight:
        if (animIdleTopRight != null) {
          animation = animIdleTopRight;
        } else {
          if (animIdleRight != null) animation = animIdleRight;
        }
        break;
      case Direction.bottomLeft:
        if (animIdleBottomLeft != null) {
          animation = animIdleBottomLeft;
        } else {
          if (animIdleLeft != null) animation = animIdleLeft;
        }
        break;
      case Direction.bottomRight:
        if (animIdleBottomRight != null) {
          animation = animIdleBottomRight;
        } else {
          if (animIdleRight != null) animation = animIdleRight;
        }
        break;
    }
  }

  void addFastAnimation(FlameAnimation.Animation animation,
      {VoidCallback onFinish}) {
    _runFastAnimation = true;
    AnimatedObjectOnce fastAnimation = AnimatedObjectOnce(
      animation: animation,
      onlyUpdate: true,
      onFinish: () {
        _runFastAnimation = false;
        idle();
        if (onFinish != null) onFinish();
      },
    );
    this.animation = fastAnimation.animation;
    gameRef.add(fastAnimation);
  }
}
