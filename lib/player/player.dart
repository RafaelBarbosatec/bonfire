import 'dart:ui';

import 'package:bonfire/joystick/joystick_controller.dart';
import 'package:bonfire/rpg_game.dart';
import 'package:bonfire/util/animated_object.dart';
import 'package:bonfire/util/animated_object_once.dart';
import 'package:bonfire/util/direction.dart';
import 'package:bonfire/util/object_collision.dart';
import 'package:flame/animation.dart' as FlameAnimation;
import 'package:flame/components/mixins/has_game_ref.dart';
import 'package:flame/position.dart';
import 'package:flutter/cupertino.dart';

export 'package:bonfire/player/extensions.dart';

class Player extends AnimatedObject
    with HasGameRef<RPGGame>, ObjectCollision
    implements JoystickListener {
  static const REDUCTION_SPEED_DIAGONAL = 0.7;

  final double width;
  final double height;
  final Position initPosition;
  final Direction initDirection;
  final FlameAnimation.Animation animIdleLeft;
  final FlameAnimation.Animation animIdleRight;
  final FlameAnimation.Animation animIdleTop;
  final FlameAnimation.Animation animIdleBottom;
  final FlameAnimation.Animation animRunTop;
  final FlameAnimation.Animation animRunRight;
  final FlameAnimation.Animation animRunBottom;
  final FlameAnimation.Animation animRunLeft;
  double speed;
  double life;
  double maxLife;
  JoystickMoveDirectional statusMoveDirectional;
  Direction lastDirection;
  Direction _lastDirectionHorizontal = Direction.right;
  bool _isDead = false;
  int lastJoystickAction;

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
    this.speed = 5,
    this.life = 10,
  }) {
    lastDirection = initDirection;
    if (initDirection == Direction.left || initDirection == Direction.right) {
      _lastDirectionHorizontal = initDirection;
    }

    if (initDirection == Direction.left)
      statusMoveDirectional = JoystickMoveDirectional.MOVE_LEFT;
    if (initDirection == Direction.right)
      statusMoveDirectional = JoystickMoveDirectional.MOVE_RIGHT;

    position = Rect.fromLTWH(
      initPosition.x,
      initPosition.y,
      width,
      height,
    );

    widthCollision = width;
    heightCollision = height / 2;
    maxLife = life;
    idle();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
  }

  @override
  void update(double dt) {
    super.update(dt);
  }

  @override
  void joystickAction(int action) {
    if (_isDead) return;
    lastJoystickAction = action;
  }

  @override
  void joystickChangeDirectional(JoystickMoveDirectional directional) {
    if (_isDead) return;
    switch (directional) {
      case JoystickMoveDirectional.MOVE_TOP:
        _moveTop();
        break;
      case JoystickMoveDirectional.MOVE_TOP_LEFT:
        _moveTopLeft();
        break;
      case JoystickMoveDirectional.MOVE_TOP_RIGHT:
        _moveTopRight();
        break;
      case JoystickMoveDirectional.MOVE_RIGHT:
        _moveRight();
        break;
      case JoystickMoveDirectional.MOVE_BOTTOM:
        _moveBottom();
        break;
      case JoystickMoveDirectional.MOVE_BOTTOM_RIGHT:
        _moveBottomRight();
        break;
      case JoystickMoveDirectional.MOVE_BOTTOM_LEFT:
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
    double speed =
        isDiagonal ? this.speed * REDUCTION_SPEED_DIAGONAL : this.speed;
    if (position.top <= 0) {
      return;
    }

    Rect displacement = position.translate(0, (speed * -1));

    if (isCollision(displacement, gameRef)) {
      return;
    }

    if (position.top > gameRef.size.height / 2.9 || gameRef.map.isMaxTop()) {
      position = displacement;
    } else {
      gameRef.map.moveCamera(speed, JoystickMoveDirectional.MOVE_TOP);
    }

    if (addAnimation &&
        statusMoveDirectional != JoystickMoveDirectional.MOVE_TOP) {
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
    statusMoveDirectional = JoystickMoveDirectional.MOVE_TOP;
    lastDirection = Direction.top;
  }

  void _moveRight({bool addAnimation = true, bool isDiagonal = false}) {
    double speed =
        isDiagonal ? this.speed * REDUCTION_SPEED_DIAGONAL : this.speed;
    if (position.right >= gameRef.size.width) {
      return;
    }

    Rect displacement = position.translate(speed, 0);

    if (isCollision(displacement, gameRef)) {
      return;
    }

    if (position.left < gameRef.size.width / 1.5 || gameRef.map.isMaxRight()) {
      position = displacement;
    } else {
      gameRef.map.moveCamera(speed, JoystickMoveDirectional.MOVE_RIGHT);
    }

    if (addAnimation &&
        statusMoveDirectional != JoystickMoveDirectional.MOVE_RIGHT &&
        animRunRight != null) {
      animation = animRunRight;
    }
    statusMoveDirectional = JoystickMoveDirectional.MOVE_RIGHT;
    lastDirection = Direction.right;
    _lastDirectionHorizontal = Direction.right;
  }

  void _moveBottom({bool addAnimation = true, bool isDiagonal = false}) {
    double speed =
        isDiagonal ? this.speed * REDUCTION_SPEED_DIAGONAL : this.speed;

    if (position.bottom >= gameRef.size.height) {
      return;
    }

    Rect displacement = position.translate(0, speed);

    if (isCollision(displacement, gameRef)) {
      return;
    }

    if (position.top < gameRef.size.height / 1.9 || gameRef.map.isMaxBottom()) {
      position = displacement;
    } else {
      gameRef.map.moveCamera(speed, JoystickMoveDirectional.MOVE_BOTTOM);
    }

    if (addAnimation &&
        statusMoveDirectional != JoystickMoveDirectional.MOVE_BOTTOM) {
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
    statusMoveDirectional = JoystickMoveDirectional.MOVE_BOTTOM;
    lastDirection = Direction.bottom;
  }

  void _moveLeft({bool addAnimation = true, bool isDiagonal = false}) {
    double speed =
        isDiagonal ? this.speed * REDUCTION_SPEED_DIAGONAL : this.speed;

    if (position.left <= 0) {
      return;
    }
    Rect displacement = position.translate(speed * -1, 0);

    if (isCollision(displacement, gameRef)) {
      return;
    }

    if (position.left > gameRef.size.width / 3 || gameRef.map.isMaxLeft()) {
      position = displacement;
    } else {
      gameRef.map.moveCamera(speed, JoystickMoveDirectional.MOVE_LEFT);
    }

    if (addAnimation &&
        statusMoveDirectional != JoystickMoveDirectional.MOVE_LEFT &&
        animRunLeft != null) {
      animation = animRunLeft;
    }
    statusMoveDirectional = JoystickMoveDirectional.MOVE_LEFT;
    lastDirection = Direction.left;

    _lastDirectionHorizontal = Direction.left;
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

  Rect get positionInWorld => Rect.fromLTWH(
        position.left - gameRef.mapCamera.x,
        position.top - gameRef.mapCamera.y,
        position.width,
        position.height,
      );
}
