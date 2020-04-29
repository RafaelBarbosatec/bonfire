import 'dart:ui';

import 'package:bonfire/joystick/joystick_controller.dart';
import 'package:bonfire/util/collision/collision.dart';
import 'package:bonfire/util/collision/object_collision.dart';
import 'package:bonfire/util/direction.dart';
import 'package:bonfire/util/objects/animated_object.dart';
import 'package:bonfire/util/objects/animated_object_once.dart';
import 'package:flame/animation.dart' as FlameAnimation;
import 'package:flame/position.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

export 'package:bonfire/player/extensions.dart';

class Player extends AnimatedObject
    with ObjectCollision
    implements JoystickListener {
  static const REDUCTION_SPEED_DIAGONAL = 0.7;

  /// Width of the Player.
  final double width;

  /// Height of the Player.
  final double height;

  /// World position that this Player must position yourself.
  final Position initPosition;

  /// Start direction.
  final Direction initDirection;

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

  double speed;
  double life;
  double maxLife;

  /// Variable that represents the current directional status of the joystick.
  JoystickMoveDirectional statusMoveDirectional;

  Direction lastDirection;

  Direction _lastDirectionHorizontal = Direction.right;

  bool _isDead = false;

  /// Variable that represents the last action pressed in joystick.
  int lastJoystickAction;

  bool _usePositionInWorld = true;
  bool _nextFrameUsePosition = false;

  final Size sizeCentralMovementWindow;
  Rect _rectCentralMovementWindow;

  double dtUpdate = 0;

  Player({
    @required this.animIdleLeft,
    @required this.animIdleRight,
    this.animIdleTop,
    this.animIdleBottom,
    this.animRunTop,
    @required this.animRunRight,
    this.animRunBottom,
    @required this.animRunLeft,
    this.width = 16,
    this.height = 16,
    @required this.initPosition,
    this.initDirection = Direction.right,
    this.speed = 150,
    this.life = 10,
    Collision collision,
    this.sizeCentralMovementWindow,
  }) {
    lastDirection = initDirection;
    if (initDirection == Direction.left || initDirection == Direction.right) {
      _lastDirectionHorizontal = initDirection;
      statusMoveDirectional = initDirection == Direction.left
          ? JoystickMoveDirectional.MOVE_LEFT
          : JoystickMoveDirectional.MOVE_RIGHT;
    }

    position = positionInWorld = Rect.fromLTWH(
      initPosition.x,
      initPosition.y,
      width,
      height,
    );

    this.collision = collision ?? Collision(width: width, height: height / 2);
    maxLife = life;
    idle();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (gameRef != null && gameRef.showCollisionArea) {
      drawCollision(canvas, position, gameRef.collisionAreaColor);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_nextFrameUsePosition) {
      _nextFrameUsePosition = false;
      _usePositionInWorld = false;
    }
    dtUpdate = dt;
  }

  @override
  void joystickAction(int action) {
    if (_isDead) return;
    lastJoystickAction = action;
  }

  @override
  void joystickChangeDirectional(
      JoystickMoveDirectional directional, double intensity, double radAngle) {
    if (_isDead || _usePositionInWorld) return;
    switch (directional) {
      case JoystickMoveDirectional.MOVE_UP:
        _moveTop();
        break;
      case JoystickMoveDirectional.MOVE_UP_LEFT:
        _moveTopLeft();
        break;
      case JoystickMoveDirectional.MOVE_UP_RIGHT:
        _moveTopRight();
        break;
      case JoystickMoveDirectional.MOVE_RIGHT:
        _moveRight();
        break;
      case JoystickMoveDirectional.MOVE_DOWN:
        _moveBottom();
        break;
      case JoystickMoveDirectional.MOVE_DOWN_RIGHT:
        _moveBottomRight();
        break;
      case JoystickMoveDirectional.MOVE_DOWN_LEFT:
        _moveBottomLeft();
        break;
      case JoystickMoveDirectional.MOVE_LEFT:
        _moveLeft();
        break;
      case JoystickMoveDirectional.IDLE:
        idle();
        break;
    }
  }

  void _moveTop({bool addAnimation = true, bool isDiagonal = false}) {
    if (addAnimation) {
      _addTopAnimation();
      statusMoveDirectional = JoystickMoveDirectional.MOVE_UP;
      lastDirection = Direction.top;
    }

    if (position.top <= 0) return;

    double speed =
        (isDiagonal ? this.speed * REDUCTION_SPEED_DIAGONAL : this.speed) *
            dtUpdate;

    Rect displacement = position.translate(0, (speed * -1));

    if (isCollision(displacement, gameRef)) return;

    if (position.top >= _rectCentralMovementWindow.top ||
        gameRef.gameCamera.isMaxTop()) {
      position = displacement;
    } else {
      gameRef.gameCamera.moveCamera(speed, JoystickMoveDirectional.MOVE_UP);
    }
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

  void _moveRight({bool addAnimation = true, bool isDiagonal = false}) {
    if (addAnimation) _addRightAnimation();

    statusMoveDirectional = JoystickMoveDirectional.MOVE_RIGHT;
    lastDirection = Direction.right;
    _lastDirectionHorizontal = Direction.right;

    if (position.right >= gameRef.size.width) return;

    double speed =
        (isDiagonal ? this.speed * REDUCTION_SPEED_DIAGONAL : this.speed) *
            dtUpdate;

    Rect displacement = position.translate(speed, 0);

    if (isCollision(displacement, gameRef)) return;

    if (position.right <= _rectCentralMovementWindow.right ||
        gameRef.gameCamera.isMaxRight()) {
      position = displacement;
    } else {
      gameRef.gameCamera.moveCamera(speed, JoystickMoveDirectional.MOVE_RIGHT);
    }
  }

  void _addRightAnimation() {
    if (statusMoveDirectional != JoystickMoveDirectional.MOVE_RIGHT &&
        animRunRight != null) {
      animation = animRunRight;
    }
  }

  void _moveBottom({bool addAnimation = true, bool isDiagonal = false}) {
    if (addAnimation) {
      _addBottomAnimation();
      statusMoveDirectional = JoystickMoveDirectional.MOVE_DOWN;
      lastDirection = Direction.bottom;
    }

    if (position.bottom >= gameRef.size.height) return;

    double speed =
        (isDiagonal ? this.speed * REDUCTION_SPEED_DIAGONAL : this.speed) *
            dtUpdate;

    Rect displacement = position.translate(0, speed);

    if (isCollision(displacement, gameRef)) return;

    if (position.bottom <= _rectCentralMovementWindow.bottom ||
        gameRef.gameCamera.isMaxBottom()) {
      position = displacement;
    } else {
      gameRef.gameCamera.moveCamera(speed, JoystickMoveDirectional.MOVE_DOWN);
    }
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

  void _moveLeft({bool addAnimation = true, bool isDiagonal = false}) {
    if (addAnimation) _addLeftAnimation();

    statusMoveDirectional = JoystickMoveDirectional.MOVE_LEFT;
    lastDirection = Direction.left;
    _lastDirectionHorizontal = Direction.left;

    if (position.left <= 0) return;

    double speed =
        (isDiagonal ? this.speed * REDUCTION_SPEED_DIAGONAL : this.speed) *
            dtUpdate;
    Rect displacement = position.translate(speed * -1, 0);

    if (isCollision(displacement, gameRef)) return;

    if (position.left >= _rectCentralMovementWindow.left ||
        gameRef.gameCamera.isMaxLeft()) {
      position = displacement;
    } else {
      gameRef.gameCamera.moveCamera(speed, JoystickMoveDirectional.MOVE_LEFT);
    }
  }

  void _addLeftAnimation() {
    if (statusMoveDirectional != JoystickMoveDirectional.MOVE_LEFT &&
        animRunLeft != null) {
      animation = animRunLeft;
    }
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

  void _moveBottomRight() {
    _moveRight(isDiagonal: true);
    _moveBottom(addAnimation: false, isDiagonal: true);
  }

  void _moveBottomLeft() {
    _moveLeft(isDiagonal: true);
    _moveBottom(addAnimation: false, isDiagonal: true);
  }

  void _moveTopLeft() {
    _moveLeft(isDiagonal: true);
    _moveTop(addAnimation: false, isDiagonal: true);
  }

  void _moveTopRight() {
    _moveRight(isDiagonal: true);
    _moveTop(addAnimation: false, isDiagonal: true);
  }

  void receiveDamage(double damage) {
    if (life > 0) {
      life -= damage;
      if (life <= 0) {
        die();
      }
    }
  }

  void die() {
    _isDead = true;
  }

  @override
  void resize(Size size) {
    if (sizeCentralMovementWindow != null) {
      _rectCentralMovementWindow = Rect.fromLTWH(
        (size.width / 2) - (sizeCentralMovementWindow.width / 2),
        (size.height / 2) - (sizeCentralMovementWindow.height / 2),
        sizeCentralMovementWindow.width,
        sizeCentralMovementWindow.height,
      );
    } else {
      double sizeWidth = width * 3;
      double sizeHeight = height * 3;
      _rectCentralMovementWindow = Rect.fromLTWH(
        (size.width / 2) - (sizeWidth / 2),
        (size.height / 2) - (sizeHeight / 2),
        sizeWidth,
        sizeHeight,
      );
    }
  }

  bool get isDead => _isDead;

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

  void addLife(double life) {
    this.life += life;
    if (this.life > maxLife) {
      this.life = maxLife;
    }
  }

  void usePositionInWorldToRender() {
    _usePositionInWorld = true;
  }

  void usePositionToRender() {
    _nextFrameUsePosition = true;
  }

  @override
  get positionInWorld {
    if (_usePositionInWorld) return super.positionInWorld;

    return super.positionInWorld = Rect.fromLTWH(
      position.left - gameRef.gameCamera.position.x,
      position.top - gameRef.gameCamera.position.y,
      position.width,
      position.height,
    );
  }

  bool get usePositionInWorld => _usePositionInWorld;

  Rect get rectCollision => getRectCollision(position);
  Rect get rectCollisionInWorld => getRectCollision(positionInWorld);
}
