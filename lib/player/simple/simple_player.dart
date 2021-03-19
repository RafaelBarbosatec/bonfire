import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/direction_animations/simple_direction_animation.dart';
import 'package:flutter/widgets.dart';

class SimplePlayer extends Player {
  static const REDUCTION_SPEED_DIAGONAL = 0.7;
  SimpleDirectionAnimation animation;

  /// Variable that represents the current directional status of the joystick.
  JoystickMoveDirectional statusMoveDirectional;
  JoystickMoveDirectional _currentDirectional = JoystickMoveDirectional.IDLE;

  Direction lastDirection;
  Direction lastDirectionHorizontal = Direction.right;

  Position _positionToMove;

  SimplePlayer({
    @required Position initPosition,
    @required this.animation,
    Direction initDirection = Direction.right,
    double speed = 150,
    double width = 32,
    double height = 32,
    double life = 100,
    Size sizeCentralMovementWindow,
  }) : super(
          initPosition: initPosition,
          width: width,
          height: height,
          life: life,
          speed: speed,
        ) {
    lastDirection = initDirection;
    if (initDirection == Direction.left || initDirection == Direction.right) {
      lastDirectionHorizontal = initDirection;
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
    animation?.render(canvas);
    super.render(canvas);
  }

  @override
  void update(double dt) {
    if (!this.isDead) {
      if (_positionToMove != null) {
        moveToPosition();
      } else {
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
    }
    animation?.update(dt, position);
    super.update(dt);
  }

  void customMoveTop(
      {bool addAnimation = true,
      bool isDiagonal = false,
      VoidCallback onCollision}) {
    if (addAnimation) {
      _addTopAnimation();
      statusMoveDirectional = JoystickMoveDirectional.MOVE_UP;
      lastDirection = Direction.top;
    }

    double speed =
        (isDiagonal ? this.speed * REDUCTION_SPEED_DIAGONAL : this.speed);

    this.moveTop(speed, onCollision: onCollision);
  }

  void _addTopAnimation() {
    if (statusMoveDirectional != JoystickMoveDirectional.MOVE_UP) {
      if (animation?.runTop != null) {
        animation?.play(SimpleAnimationEnum.runTop);
      } else {
        if (lastDirectionHorizontal == Direction.left) {
          animation?.play(SimpleAnimationEnum.runLeft);
        } else {
          animation?.play(SimpleAnimationEnum.runRight);
        }
      }
    }
  }

  void customMoveRight(
      {bool addAnimation = true,
      bool isDiagonal = false,
      VoidCallback onCollision}) {
    if (statusMoveDirectional != JoystickMoveDirectional.MOVE_RIGHT &&
        animation?.runRight != null &&
        addAnimation) {
      animation?.play(SimpleAnimationEnum.runRight);
      statusMoveDirectional = JoystickMoveDirectional.MOVE_RIGHT;
      lastDirection = Direction.right;
      lastDirectionHorizontal = Direction.right;
    }
    double speed =
        (isDiagonal ? this.speed * REDUCTION_SPEED_DIAGONAL : this.speed);

    this.moveRight(speed, onCollision: onCollision);
  }

  void customMoveBottom(
      {bool addAnimation = true,
      bool isDiagonal = false,
      VoidCallback onCollision}) {
    if (addAnimation) {
      _addBottomAnimation();
      statusMoveDirectional = JoystickMoveDirectional.MOVE_DOWN;
      lastDirection = Direction.bottom;
    }

    double speed =
        (isDiagonal ? this.speed * REDUCTION_SPEED_DIAGONAL : this.speed);

    this.moveBottom(speed, onCollision: onCollision);
  }

  void _addBottomAnimation() {
    if (statusMoveDirectional != JoystickMoveDirectional.MOVE_DOWN) {
      if (animation?.runBottom != null) {
        animation?.play(SimpleAnimationEnum.runBottom);
      } else {
        if (lastDirectionHorizontal == Direction.left) {
          animation?.play(SimpleAnimationEnum.runLeft);
        } else {
          animation?.play(SimpleAnimationEnum.runRight);
        }
      }
    }
  }

  void customMoveLeft(
      {bool addAnimation = true,
      bool isDiagonal = false,
      VoidCallback onCollision}) {
    if (statusMoveDirectional != JoystickMoveDirectional.MOVE_LEFT &&
        animation.runLeft != null &&
        addAnimation) {
      animation?.play(SimpleAnimationEnum.runLeft);
      statusMoveDirectional = JoystickMoveDirectional.MOVE_LEFT;
      lastDirection = Direction.left;
      lastDirectionHorizontal = Direction.left;
    }

    double speed =
        (isDiagonal ? this.speed * REDUCTION_SPEED_DIAGONAL : this.speed);

    this.moveLeft(speed, onCollision: onCollision);
  }

  void customMoveUpLeft() {
    if (animation.runTopLeft != null &&
        statusMoveDirectional != JoystickMoveDirectional.MOVE_UP_LEFT) {
      animation?.play(SimpleAnimationEnum.runTopLeft);
      lastDirection = Direction.topLeft;
      statusMoveDirectional = JoystickMoveDirectional.MOVE_UP_LEFT;
    }
    customMoveLeft(
      addAnimation: animation.runTopLeft == null,
      isDiagonal: true,
    );
    customMoveTop(
      addAnimation: false,
      isDiagonal: true,
    );
  }

  void customMoveUpRight() {
    if (animation?.runTopRight != null &&
        statusMoveDirectional != JoystickMoveDirectional.MOVE_UP_RIGHT) {
      animation?.play(SimpleAnimationEnum.runTopRight);
      lastDirection = Direction.topRight;
      statusMoveDirectional = JoystickMoveDirectional.MOVE_UP_RIGHT;
    }
    customMoveRight(
      addAnimation: animation?.runTopRight == null,
      isDiagonal: true,
    );
    customMoveTop(
      addAnimation: false,
      isDiagonal: true,
    );
  }

  void customMoveDownRight() {
    if (animation?.runBottomRight != null &&
        statusMoveDirectional != JoystickMoveDirectional.MOVE_DOWN_RIGHT) {
      animation?.play(SimpleAnimationEnum.runBottomRight);
      lastDirection = Direction.bottomRight;
      statusMoveDirectional = JoystickMoveDirectional.MOVE_DOWN_RIGHT;
    }
    customMoveRight(
      addAnimation: animation?.runBottomRight == null,
      isDiagonal: true,
    );
    customMoveBottom(
      addAnimation: false,
      isDiagonal: true,
    );
  }

  void customMoveDownLeft() {
    if (animation?.runBottomLeft != null &&
        statusMoveDirectional != JoystickMoveDirectional.MOVE_DOWN_LEFT) {
      animation?.play(SimpleAnimationEnum.runBottomLeft);
      lastDirection = Direction.bottomLeft;
      statusMoveDirectional = JoystickMoveDirectional.MOVE_DOWN_LEFT;
    }
    customMoveLeft(
        addAnimation: animation?.runBottomLeft == null, isDiagonal: true);
    customMoveBottom(addAnimation: false, isDiagonal: true);
  }

  void idle({bool forceAddAnimation = false}) {
    if (statusMoveDirectional != JoystickMoveDirectional.IDLE ||
        forceAddAnimation) {
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
          if (animation.idleBottom != null) {
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
    statusMoveDirectional = JoystickMoveDirectional.IDLE;
  }

  @override
  void moveTo(Position position) {
    _positionToMove = position;
    super.moveTo(position);
  }

  void moveToPosition() {
    bool move = false;

    if (_positionToMove.x > position.center.dx &&
        _positionToMove.x - position.center.dx > 1) {
      move = true;
      customMoveRight(
        onCollision: () {
          _positionToMove = null;
        },
      );
    }
    if (_positionToMove == null) return;
    if (_positionToMove.x < position.center.dx &&
        position.center.dx - _positionToMove.x > 1) {
      move = true;
      customMoveLeft(
        onCollision: () {
          _positionToMove = null;
          return;
        },
      );
    }
    if (_positionToMove == null) return;
    if (_positionToMove.y > position.center.dy &&
        _positionToMove.y - position.center.dy > 1) {
      move = true;
      customMoveBottom(
        onCollision: () {
          _positionToMove = null;
          return;
        },
      );
    }
    if (_positionToMove == null) return;
    if (_positionToMove.y < position.center.dy &&
        position.center.dy - _positionToMove.y > 1) {
      move = true;
      customMoveTop(
        onCollision: () {
          _positionToMove = null;
          return;
        },
      );
    }
    if (!move) {
      idle(forceAddAnimation: true);
      _positionToMove = null;
    }
  }
}
