import 'package:bonfire/bonfire.dart';
import 'package:bonfire/player/simple/simple_player_animation.dart';
import 'package:flutter/widgets.dart';

class SimplePlayer extends Player {
  static const REDUCTION_SPEED_DIAGONAL = 0.7;
  SimplePlayerAnimation newAnimation;

  /// Variable that represents the current directional status of the joystick.
  JoystickMoveDirectional statusMoveDirectional;
  JoystickMoveDirectional _currentDirectional = JoystickMoveDirectional.IDLE;

  Direction lastDirection;
  Direction _lastDirectionHorizontal = Direction.right;

  double speed;

  SimplePlayer({
    @required Position initPosition,
    @required this.newAnimation,
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
        ) {
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
  void render(Canvas canvas) {
    newAnimation.render(canvas, position);
    super.render(canvas);
  }

  @override
  void update(double dt) {
    if (!this.isDead) {
      switch (_currentDirectional) {
        case JoystickMoveDirectional.MOVE_UP:
          customMoveTop();
          break;
        case JoystickMoveDirectional.MOVE_UP_LEFT:
          customMoveUpLeft();
          break;
        case JoystickMoveDirectional.MOVE_UP_RIGHT:
          customMoveUpRight();
          break;
        case JoystickMoveDirectional.MOVE_RIGHT:
          customMoveRight();
          break;
        case JoystickMoveDirectional.MOVE_DOWN:
          customMoveBottom();
          break;
        case JoystickMoveDirectional.MOVE_DOWN_RIGHT:
          customMoveDownRight();
          break;
        case JoystickMoveDirectional.MOVE_DOWN_LEFT:
          customMoveDownLeft();
          break;
        case JoystickMoveDirectional.MOVE_LEFT:
          customMoveLeft();
          break;
        case JoystickMoveDirectional.IDLE:
          idle();
          break;
      }
    }
    newAnimation.update(dt);
    super.update(dt);
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
      if (newAnimation.runTop != null) {
        newAnimation.play(SimplePlayerAnimationEnum.runTop);
      } else {
        if (_lastDirectionHorizontal == Direction.left) {
          newAnimation.play(SimplePlayerAnimationEnum.runLeft);
        } else {
          newAnimation.play(SimplePlayerAnimationEnum.runRight);
        }
      }
    }
  }

  void customMoveRight({bool addAnimation = true, bool isDiagonal = false}) {
    if (statusMoveDirectional != JoystickMoveDirectional.MOVE_RIGHT &&
        newAnimation.runRight != null &&
        addAnimation) {
      newAnimation.play(SimplePlayerAnimationEnum.runRight);
      statusMoveDirectional = JoystickMoveDirectional.MOVE_RIGHT;
      lastDirection = Direction.right;
      _lastDirectionHorizontal = Direction.right;
    }
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
      if (newAnimation.runBottom != null) {
        newAnimation.play(SimplePlayerAnimationEnum.runBottom);
      } else {
        if (_lastDirectionHorizontal == Direction.left) {
          newAnimation.play(SimplePlayerAnimationEnum.runLeft);
        } else {
          newAnimation.play(SimplePlayerAnimationEnum.runRight);
        }
      }
    }
  }

  void customMoveLeft({bool addAnimation = true, bool isDiagonal = false}) {
    if (statusMoveDirectional != JoystickMoveDirectional.MOVE_LEFT &&
        newAnimation.runLeft != null &&
        addAnimation) {
      newAnimation.play(SimplePlayerAnimationEnum.runLeft);
      statusMoveDirectional = JoystickMoveDirectional.MOVE_LEFT;
      lastDirection = Direction.left;
      _lastDirectionHorizontal = Direction.left;
    }

    double speed =
        (isDiagonal ? this.speed * REDUCTION_SPEED_DIAGONAL : this.speed);

    this.moveLeft(speed);
  }

  void customMoveUpLeft() {
    if (newAnimation.runTopLeft != null &&
        statusMoveDirectional != JoystickMoveDirectional.MOVE_UP_LEFT) {
      newAnimation.play(SimplePlayerAnimationEnum.runTopLeft);
      lastDirection = Direction.topLeft;
      statusMoveDirectional = JoystickMoveDirectional.MOVE_UP_LEFT;
    }
    customMoveLeft(
      addAnimation: newAnimation.runTopLeft == null,
      isDiagonal: true,
    );
    customMoveTop(
      addAnimation: false,
      isDiagonal: true,
    );
  }

  void customMoveUpRight() {
    if (newAnimation.runTopRight != null &&
        statusMoveDirectional != JoystickMoveDirectional.MOVE_UP_RIGHT) {
      newAnimation.play(SimplePlayerAnimationEnum.runTopRight);
      lastDirection = Direction.topRight;
      statusMoveDirectional = JoystickMoveDirectional.MOVE_UP_RIGHT;
    }
    customMoveRight(
      addAnimation: newAnimation.runTopRight == null,
      isDiagonal: true,
    );
    customMoveTop(
      addAnimation: false,
      isDiagonal: true,
    );
  }

  void customMoveDownRight() {
    if (newAnimation.runBottomRight != null &&
        statusMoveDirectional != JoystickMoveDirectional.MOVE_DOWN_RIGHT) {
      newAnimation.play(SimplePlayerAnimationEnum.runBottomRight);
      lastDirection = Direction.bottomRight;
      statusMoveDirectional = JoystickMoveDirectional.MOVE_DOWN_RIGHT;
    }
    customMoveRight(
      addAnimation: newAnimation.runBottomRight == null,
      isDiagonal: true,
    );
    customMoveBottom(
      addAnimation: false,
      isDiagonal: true,
    );
  }

  void customMoveDownLeft() {
    if (newAnimation.runBottomLeft != null &&
        statusMoveDirectional != JoystickMoveDirectional.MOVE_DOWN_LEFT) {
      newAnimation.play(SimplePlayerAnimationEnum.runBottomLeft);
      lastDirection = Direction.bottomLeft;
      statusMoveDirectional = JoystickMoveDirectional.MOVE_DOWN_LEFT;
    }
    customMoveLeft(
        addAnimation: newAnimation.runBottomLeft == null, isDiagonal: true);
    customMoveBottom(addAnimation: false, isDiagonal: true);
  }

  void idle({bool forceAddAnimation = false}) {
    if (statusMoveDirectional != JoystickMoveDirectional.IDLE ||
        forceAddAnimation) {
      switch (lastDirection) {
        case Direction.left:
          newAnimation.play(SimplePlayerAnimationEnum.idleLeft);
          break;
        case Direction.right:
          newAnimation.play(SimplePlayerAnimationEnum.idleRight);
          break;
        case Direction.top:
          if (newAnimation.idleTop != null) {
            newAnimation.play(SimplePlayerAnimationEnum.idleTop);
          } else {
            if (_lastDirectionHorizontal == Direction.left) {
              newAnimation.play(SimplePlayerAnimationEnum.idleLeft);
            } else {
              newAnimation.play(SimplePlayerAnimationEnum.idleRight);
            }
          }
          break;
        case Direction.bottom:
          if (newAnimation.idleBottom != null) {
            newAnimation.play(SimplePlayerAnimationEnum.idleBottom);
          } else {
            if (_lastDirectionHorizontal == Direction.left) {
              newAnimation.play(SimplePlayerAnimationEnum.idleLeft);
            } else {
              newAnimation.play(SimplePlayerAnimationEnum.idleRight);
            }
          }
          break;
        case Direction.topLeft:
          if (newAnimation.idleTopLeft != null) {
            newAnimation.play(SimplePlayerAnimationEnum.idleTopLeft);
          } else {
            newAnimation.play(SimplePlayerAnimationEnum.idleLeft);
          }
          break;
        case Direction.topRight:
          if (newAnimation.idleTopRight != null) {
            newAnimation.play(SimplePlayerAnimationEnum.idleTopRight);
          } else {
            newAnimation.play(SimplePlayerAnimationEnum.idleRight);
          }
          break;
        case Direction.bottomLeft:
          if (newAnimation.idleBottomLeft != null) {
            newAnimation.play(SimplePlayerAnimationEnum.idleBottomLeft);
          } else {
            newAnimation.play(SimplePlayerAnimationEnum.idleLeft);
          }
          break;
        case Direction.bottomRight:
          if (newAnimation.idleBottomRight != null) {
            newAnimation.play(SimplePlayerAnimationEnum.idleBottomRight);
          } else {
            newAnimation.play(SimplePlayerAnimationEnum.idleRight);
          }
          break;
      }
    }
    statusMoveDirectional = JoystickMoveDirectional.IDLE;
  }
}
