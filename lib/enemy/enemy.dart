import 'dart:async';
import 'dart:ui';

import 'package:bonfire/util/animated_object.dart';
import 'package:bonfire/util/animated_object_once.dart';
import 'package:bonfire/util/direction.dart';
import 'package:bonfire/util/object_collision.dart';
import 'package:flame/animation.dart' as FlameAnimation;
import 'package:flame/position.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

export 'package:bonfire/enemy/extensions.dart';

/// It is used to represent your enemies.
class Enemy extends AnimatedObject with ObjectCollision {
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

  /// Height of the Enemy.
  final double height;

  /// Width of the Enemy.
  final double width;

  /// World position that this enemy must position yourself.
  final Position initPosition;

  /// Whether to draw the default life bar.
  final bool drawDefaultLife;

  /// Life of the Enemy.
  double life;

  /// Max life of the Enemy.
  double maxLife;

  bool _isDead = false;

  /// Last position the enemy was in.
  Direction lastDirection;

  /// Last horizontal position the enemy was in.
  Direction lastDirectionHorizontal;

  /// Map available to store times that can be used to control the frequency of any action.
  Map<String, Timer> timers = Map();

  Enemy({
    @required this.animationIdleRight,
    @required this.animationIdleLeft,
    this.animationIdleTop,
    this.animationIdleBottom,
    this.animationRunTop,
    @required this.animationRunRight,
    @required this.animationRunLeft,
    this.animationRunBottom,
    @required this.initPosition,
    @required this.height,
    @required this.width,
    Direction initDirection = Direction.right,
    this.speed = 3,
    this.life = 10,
    this.drawDefaultLife = true,
  }) {
    lastDirection = initDirection;
    maxLife = life;
    this.position = this.positionInWorld = Rect.fromLTWH(
      initPosition.x,
      initPosition.y,
      width,
      height,
    );
    widthCollision = width;
    heightCollision = height / 3;

    lastDirectionHorizontal =
        initDirection == Direction.left ? Direction.left : Direction.right;

    idle();
  }

  bool get isDead => _isDead;

  @override
  void render(Canvas canvas) {
    if (isVisibleInMap()) {
      if (drawDefaultLife) {
        _drawLife(canvas);
      }
      super.render(canvas);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
  }

  void _drawLife(Canvas canvas) {
    canvas.drawLine(
        Offset(position.left, position.top - 4),
        Offset(position.left + width, position.top - 4),
        Paint()
          ..color = Colors.black
          ..strokeWidth = 2
          ..style = PaintingStyle.fill);

    double currentBarLife = (life * width) / maxLife;

    canvas.drawLine(
        Offset(position.left, position.top - 4),
        Offset(position.left + currentBarLife, position.top - 4),
        Paint()
          ..color = _getColorLife(currentBarLife)
          ..strokeWidth = 2
          ..style = PaintingStyle.fill);
  }

  Color _getColorLife(double currentBarLife) {
    if (currentBarLife > width - (width / 3)) {
      return Colors.green;
    }
    if (currentBarLife > (width / 3)) {
      return Colors.yellow;
    } else {
      return Colors.red;
    }
  }

  void translate(double translateX, double translateY) {
    positionInWorld = positionInWorld.translate(translateX, translateY);
  }

  void moveTop({double moveSpeed}) {
    double speed = moveSpeed ?? this.speed;

    var collision = isCollisionTranslate(
      position,
      0,
      (speed * -1),
      gameRef,
    );

    if (collision) return;

    positionInWorld = positionInWorld.translate(0, (speed * -1));

    if (lastDirection != Direction.top) {
      animation = animationRunTop ??
          (lastDirectionHorizontal == Direction.right
              ? animationRunRight
              : animationRunLeft);
      lastDirection = Direction.top;
    }
  }

  void moveBottom({double moveSpeed}) {
    double speed = moveSpeed ?? this.speed;

    var collision = isCollisionTranslate(
      position,
      0,
      speed,
      gameRef,
    );
    if (collision) return;

    positionInWorld = positionInWorld.translate(0, speed);

    if (lastDirection != Direction.bottom) {
      animation = animationRunBottom ??
          (lastDirectionHorizontal == Direction.right
              ? animationRunRight
              : animationRunLeft);
      lastDirection = Direction.bottom;
    }
  }

  void moveLeft({double moveSpeed}) {
    double speed = moveSpeed ?? this.speed;

    var collision = isCollisionTranslate(
      position,
      (speed * -1),
      0,
      gameRef,
    );
    if (collision) return;

    positionInWorld = positionInWorld.translate((speed * -1), 0);
    if (lastDirection != Direction.left) {
      animation = animationRunLeft;
      lastDirection = Direction.left;
    }
    lastDirectionHorizontal = Direction.left;
  }

  void moveRight({double moveSpeed}) {
    double speed = moveSpeed ?? this.speed;

    var collision = isCollisionTranslate(
      position,
      speed,
      0,
      gameRef,
    );

    if (collision) return;

    positionInWorld = positionInWorld.translate(speed, 0);
    if (lastDirection != Direction.right) {
      animation = animationRunRight;
      lastDirection = Direction.right;
    }
    lastDirectionHorizontal = Direction.right;
  }

  void idle() {
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

  void receiveDamage(double damage) {
    if (life > 0) {
      life -= damage;
      if (life <= 0) {
        die();
      }
    }
  }

  void addLife(double life) {
    this.life += life;
    if (this.life > maxLife) {
      this.life = maxLife;
    }
  }

  void die() {
    _isDead = true;
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

  bool checkPassedInterval(String name, int intervalInMilli) {
    if (this.timers[name] == null) {
      this.timers[name] = Timer(
        Duration(milliseconds: intervalInMilli),
        () {
          this.timers[name] = null;
        },
      );
      return true;
    } else {
      return false;
    }
  }
}
