import 'package:bonfire/bonfire.dart';
import 'package:flame/animation.dart' as FlameAnimation;
import 'package:flutter/widgets.dart';

class SimpleEnemy extends Enemy {
  /// Animation that was used when enemy stay stopped on the right.
  final FlameAnimation.Animation animationIdleRight;

  /// Animation that was used when enemy stay stopped on the left.
  final FlameAnimation.Animation animationIdleLeft;

  /// Animation that was used when enemy stay stopped on the top.
  final FlameAnimation.Animation animationIdleTop;

  /// Animation that was used when enemy stay stopped on the bottom.
  final FlameAnimation.Animation animationIdleBottom;

  /// Animation used when the enemy walks to the top.
  final FlameAnimation.Animation animationRunTop;

  /// Animation used when the enemy walks to the right.
  final FlameAnimation.Animation animationRunRight;

  /// Animation used when the enemy walks to the left.
  final FlameAnimation.Animation animationRunLeft;

  /// Animation used when the enemy walks to the bottom.
  final FlameAnimation.Animation animationRunBottom;

  /// Variable that represents the speed of the enemy.
  final double speed;

  /// Last position the enemy was in.
  Direction lastDirection;

  /// Last horizontal position the enemy was in.
  Direction lastDirectionHorizontal;

  bool _isIdle = true;

  SimpleEnemy({
    @required Position initPosition,
    @required double height,
    @required double width,
    @required this.animationIdleRight,
    @required this.animationIdleLeft,
    @required this.animationRunRight,
    @required this.animationRunLeft,
    double life = 100,
    this.animationIdleTop,
    this.animationIdleBottom,
    this.animationRunTop,
    this.animationRunBottom,
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
    this.moveTop(moveSpeed);

    if ((lastDirection != Direction.top || _isIdle) && addAnimation) {
      _isIdle = false;
      animation = animationRunTop ??
          (lastDirectionHorizontal == Direction.right
              ? animationRunRight
              : animationRunLeft);
      lastDirection = Direction.top;
    }
  }

  void customMoveBottom(double speed, {bool addAnimation = true}) {
    this.moveBottom(speed);
    if ((lastDirection != Direction.bottom || _isIdle) && addAnimation) {
      _isIdle = false;
      animation = animationRunBottom ??
          (lastDirectionHorizontal == Direction.right
              ? animationRunRight
              : animationRunLeft);
      lastDirection = Direction.bottom;
    }
  }

  void customMoveLeft(double speed) {
    this.moveLeft(speed);
    if (lastDirection != Direction.left || _isIdle) {
      _isIdle = false;
      animation = animationRunLeft;
      lastDirection = Direction.left;
    }
    lastDirectionHorizontal = Direction.left;
  }

  void customMoveRight(double speed) {
    this.moveRight(speed);
    if (lastDirection != Direction.right || _isIdle) {
      _isIdle = false;
      animation = animationRunRight;
      lastDirection = Direction.right;
    }
    lastDirectionHorizontal = Direction.right;
  }

  void idle() {
    _isIdle = true;
    switch (lastDirection) {
      case Direction.left:
        animation = animationIdleLeft;
        break;
      case Direction.right:
        animation = animationIdleRight;
        break;
      case Direction.top:
        if (animationIdleTop != null) {
          animation = animationIdleTop;
        } else {
          if (lastDirectionHorizontal == Direction.left) {
            animation = animationIdleLeft;
          } else {
            animation = animationIdleRight;
          }
        }
        break;
      case Direction.bottom:
        if (animationIdleBottom != null) {
          animation = animationIdleBottom;
        } else {
          if (lastDirectionHorizontal == Direction.left) {
            animation = animationIdleLeft;
          } else {
            animation = animationIdleRight;
          }
        }

        break;
    }
  }

  void addFastAnimation(FlameAnimation.Animation animation) {
    AnimatedObjectOnce fastAnimation = AnimatedObjectOnce(
      animation: animation,
      onlyUpdate: true,
      onFinish: () {
        idle();
      },
    );
    this.animation = fastAnimation.animation;
    gameRef.add(fastAnimation);
  }
}
