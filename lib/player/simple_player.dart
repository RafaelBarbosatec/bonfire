import 'package:bonfire/bonfire.dart';
import 'package:flame/animation.dart' as FlameAnimation;
import 'package:flutter/widgets.dart';

class SimplePlayer extends Player {
  static const REDUCTION_SPEED_DIAGONAL = 0.7;

  /// Animation that was used when player stay stopped on the left.
  final FlameAnimation.Animation animIdleLeft;

  /// Animation that was used when player stay stopped on the right.
  final FlameAnimation.Animation animIdleRight;

  /// Animation that was used when player stay stopped on the top.
  final FlameAnimation.Animation animIdleTop;

  /// Animation that was used when player stay stopped on the bottom.
  final FlameAnimation.Animation animIdleBottom;

  /// Animation used when the player walks to the top.
  final FlameAnimation.Animation animRunTop;

  /// Animation used when the player walks to the right.
  final FlameAnimation.Animation animRunRight;

  /// Animation used when the player walks to the bottom.
  final FlameAnimation.Animation animRunBottom;

  /// Animation used when the player walks to the left.
  final FlameAnimation.Animation animRunLeft;

  /// Variable that represents the current directional status of the joystick.
  JoystickMoveDirectional statusMoveDirectional;
  JoystickMoveDirectional _currentDirectional = JoystickMoveDirectional.IDLE;

  Direction lastDirection;
  Direction _lastDirectionHorizontal = Direction.right;

  double speed;

  SimplePlayer({
    @required Position initPosition,
    @required this.animIdleLeft,
    @required this.animIdleRight,
    @required this.animRunRight,
    @required this.animRunLeft,
    this.animIdleTop,
    this.animIdleBottom,
    this.animRunTop,
    this.animRunBottom,
    Direction initDirection = Direction.right,
    this.speed = 150,
    double width = 32,
    double height = 32,
    double life = 100,
    Collision collision,
    Size sizeCentralMovementWindow,
  }) : super(
            initPosition: initPosition,
            width: width,
            height: height,
            life: life,
            collision: collision,
            sizeCentralMovementWindow: sizeCentralMovementWindow) {
    lastDirection = initDirection;
    if (initDirection == Direction.left || initDirection == Direction.right) {
      _lastDirectionHorizontal = initDirection;
      statusMoveDirectional = initDirection == Direction.left
          ? JoystickMoveDirectional.MOVE_LEFT
          : JoystickMoveDirectional.MOVE_RIGHT;
    }
    idle();
  }

  @override
  void joystickChangeDirectional(JoystickDirectionalEvent event) {
    _currentDirectional = event.directional;
  }

  @override
  void update(double dt) {
    if (!this.isDead) {
      switch (_currentDirectional) {
        case JoystickMoveDirectional.MOVE_UP:
          customMoveTop();
          break;
        case JoystickMoveDirectional.MOVE_UP_LEFT:
          customMoveLeft(isDiagonal: true);
          customMoveTop(addAnimation: false, isDiagonal: true);
          break;
        case JoystickMoveDirectional.MOVE_UP_RIGHT:
          customMoveRight(isDiagonal: true);
          customMoveTop(addAnimation: false, isDiagonal: true);
          break;
        case JoystickMoveDirectional.MOVE_RIGHT:
          customMoveRight();
          break;
        case JoystickMoveDirectional.MOVE_DOWN:
          customMoveBottom();
          break;
        case JoystickMoveDirectional.MOVE_DOWN_RIGHT:
          customMoveRight(isDiagonal: true);
          customMoveBottom(addAnimation: false, isDiagonal: true);
          break;
        case JoystickMoveDirectional.MOVE_DOWN_LEFT:
          customMoveLeft(isDiagonal: true);
          customMoveBottom(addAnimation: false, isDiagonal: true);
          break;
        case JoystickMoveDirectional.MOVE_LEFT:
          customMoveLeft();
          break;
        case JoystickMoveDirectional.IDLE:
          idle();
          break;
      }
    }
    super.update(dt);
  }

  void addFastAnimation(FlameAnimation.Animation animation) {
    AnimatedObjectOnce fastAnimation = AnimatedObjectOnce(
      animation: animation,
      onlyUpdate: true,
      onFinish: () {
        idle(forceAddAnimation: true);
      },
    );
    this.animation = fastAnimation.animation;
    gameRef.add(fastAnimation);
  }

  void customMoveTop({bool addAnimation = true, bool isDiagonal = false}) {
    if (addAnimation) {
      _addTopAnimation();
      statusMoveDirectional = JoystickMoveDirectional.MOVE_UP;
      lastDirection = Direction.top;
    }

    double speed =
        (isDiagonal ? this.speed * REDUCTION_SPEED_DIAGONAL : this.speed);

    this.moveTop(speed);
  }

  void _addTopAnimation() {
    if (statusMoveDirectional != JoystickMoveDirectional.MOVE_UP) {
      if (animRunTop != null) {
        animation = animRunTop;
      } else {
        if (_lastDirectionHorizontal == Direction.left) {
          if (animRunLeft != null) animation = animRunLeft;
        } else {
          if (animRunRight != null) animation = animRunRight;
        }
      }
    }
  }

  void customMoveRight({bool isDiagonal = false}) {
    if (statusMoveDirectional != JoystickMoveDirectional.MOVE_RIGHT &&
        animRunRight != null) {
      animation = animRunRight;
    }

    statusMoveDirectional = JoystickMoveDirectional.MOVE_RIGHT;
    lastDirection = Direction.right;
    _lastDirectionHorizontal = Direction.right;

    double speed =
        (isDiagonal ? this.speed * REDUCTION_SPEED_DIAGONAL : this.speed);

    this.moveRight(speed);
  }

  void customMoveBottom({bool addAnimation = true, bool isDiagonal = false}) {
    if (addAnimation) {
      _addBottomAnimation();
      statusMoveDirectional = JoystickMoveDirectional.MOVE_DOWN;
      lastDirection = Direction.bottom;
    }

    double speed =
        (isDiagonal ? this.speed * REDUCTION_SPEED_DIAGONAL : this.speed);

    this.moveBottom(speed);
  }

  void _addBottomAnimation() {
    if (statusMoveDirectional != JoystickMoveDirectional.MOVE_DOWN) {
      if (animRunBottom != null) {
        animation = animRunBottom;
      } else {
        if (_lastDirectionHorizontal == Direction.left) {
          if (animRunLeft != null) animation = animRunLeft;
        } else {
          if (animRunRight != null) animation = animRunRight;
        }
      }
    }
  }

  void customMoveLeft({bool isDiagonal = false}) {
    if (statusMoveDirectional != JoystickMoveDirectional.MOVE_LEFT &&
        animRunLeft != null) {
      animation = animRunLeft;
    }
    statusMoveDirectional = JoystickMoveDirectional.MOVE_LEFT;
    lastDirection = Direction.left;
    _lastDirectionHorizontal = Direction.left;

    double speed =
        (isDiagonal ? this.speed * REDUCTION_SPEED_DIAGONAL : this.speed);

    this.moveLeft(speed);
  }

  void idle({bool forceAddAnimation = false}) {
    if (statusMoveDirectional != JoystickMoveDirectional.IDLE ||
        forceAddAnimation) {
      switch (lastDirection) {
        case Direction.left:
          if (animIdleLeft != null) animation = animIdleLeft;
          break;
        case Direction.right:
          if (animIdleRight != null) animation = animIdleRight;
          break;
        case Direction.top:
          if (animIdleTop != null) {
            animation = animIdleTop;
          } else {
            if (_lastDirectionHorizontal == Direction.left) {
              if (animIdleLeft != null) animation = animIdleLeft;
            } else {
              if (animIdleRight != null) animation = animIdleRight;
            }
          }
          break;
        case Direction.bottom:
          if (animIdleBottom != null) {
            animation = animIdleBottom;
          } else {
            if (_lastDirectionHorizontal == Direction.left) {
              if (animIdleLeft != null) animation = animIdleLeft;
            } else {
              if (animIdleRight != null) animation = animIdleRight;
            }
          }
          break;
      }
    }
    statusMoveDirectional = JoystickMoveDirectional.IDLE;
  }
}
