import 'dart:ui';

import 'package:bonfire/enemy/enemy.dart';
import 'package:bonfire/player/player.dart';
import 'package:bonfire/util/animated_object_once.dart';
import 'package:bonfire/util/direction.dart';
import 'package:bonfire/util/flying_attack_object.dart';
import 'package:bonfire/util/text_damage.dart';
import 'package:flame/animation.dart' as FlameAnimation;
import 'package:flame/position.dart';
import 'package:flame/text_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

extension EnemyExtensions on Enemy {
  void seePlayer({
    Function(Player) observed,
    Function() notObserved,
    int visionCells = 3,
  }) {
    Player player = gameRef.player;
    if (!isVisibleInMap() || player == null) return;

    if (player.isDead) {
      if (notObserved != null) notObserved();
      return;
    }

    double visionWidth = position.width * visionCells * 2;
    double visionHeight = position.height * visionCells * 2;

    Rect fieldOfVision = Rect.fromLTWH(
      position.left - (visionWidth / 2),
      position.top - (visionHeight / 2),
      visionWidth,
      visionHeight,
    );

    if (fieldOfVision.overlaps(player.position)) {
      if (observed != null) observed(player);
    } else {
      if (notObserved != null) notObserved();
    }
  }

  void seeAndMoveToPlayer({Function(Player) closePlayer, int visionCells = 3}) {
    if (!isVisibleInMap() || isDead) return;
    seePlayer(
      visionCells: visionCells,
      observed: (player) {
        double centerXPlayer = player.position.center.dx;
        double centerYPlayer = player.position.center.dy;

        double translateX = 0;
        double translateY = 0;

        translateX = position.center.dx > centerXPlayer ? (-1 * speed) : speed;
        translateX = _adjustTranslate(
          translateX,
          position.center.dx,
          centerXPlayer,
        );
        translateY = position.center.dy > centerYPlayer ? (-1 * speed) : speed;
        translateY = _adjustTranslate(
          translateY,
          position.center.dy,
          centerYPlayer,
        );

        if ((translateX < 0 && translateX > -0.1) ||
            (translateX > 0 && translateX < 0.1)) {
          translateX = 0;
        }

        if ((translateY < 0 && translateY > -0.1) ||
            (translateY > 0 && translateY < 0.1)) {
          translateY = 0;
        }

        if (position.overlaps(player.position)) {
          if (closePlayer != null) closePlayer(player);
          this.idle();
          return;
        }

        if (translateX > 0) {
          moveRight(moveSpeed: translateX);
        } else {
          moveLeft(moveSpeed: (translateX * -1));
        }
        if (translateY > 0) {
          moveBottom(moveSpeed: translateY);
        } else {
          moveTop(moveSpeed: (translateY * -1));
        }
      },
      notObserved: () {
        this.idle();
      },
    );
  }

  void simpleAttackMelee({
    @required double damage,
    @required double heightArea,
    @required double widthArea,
    int interval = 1000,
    FlameAnimation.Animation attackEffectRightAnim,
    FlameAnimation.Animation attackEffectBottomAnim,
    FlameAnimation.Animation attackEffectLeftAnim,
    FlameAnimation.Animation attackEffectTopAnim,
  }) {
    if (!this.checkPassedInterval('attackMelee', interval)) return;

    Player player = gameRef.player;

    if (player.isDead || !isVisibleInMap() || isDead) return;

    Rect positionAttack;
    FlameAnimation.Animation anim = attackEffectRightAnim;

    Direction playerDirection;

    double centerXPlayer = player.position.center.dx;
    double centerYPlayer = player.position.center.dy;

    double centerYEnemy = position.center.dy;
    double centerXEnemy = position.center.dx;

    double diffX = centerXEnemy - centerXPlayer;
    double diffY = centerYEnemy - centerYPlayer;

    double positiveDiffX = diffX > 0 ? diffX : diffX * -1;
    double positiveDiffY = diffY > 0 ? diffY : diffY * -1;
    if (positiveDiffX > positiveDiffY) {
      playerDirection = diffX > 0 ? Direction.left : Direction.right;
    } else {
      playerDirection = diffY > 0 ? Direction.top : Direction.bottom;
    }

    switch (playerDirection) {
      case Direction.top:
        positionAttack = Rect.fromLTWH(
          this.positionInWorld.left + (this.width - widthArea) / 2,
          this.positionInWorld.top - this.height,
          widthArea,
          heightArea,
        );
        if (attackEffectTopAnim != null) anim = attackEffectTopAnim;
        break;
      case Direction.right:
        positionAttack = Rect.fromLTWH(
          this.positionInWorld.right,
          this.positionInWorld.top + (this.height - heightArea) / 2,
          widthArea,
          heightArea,
        );
        if (attackEffectRightAnim != null) anim = attackEffectRightAnim;
        break;
      case Direction.bottom:
        positionAttack = Rect.fromLTWH(
          this.positionInWorld.left + (this.width - widthArea) / 2,
          this.positionInWorld.bottom,
          widthArea,
          heightArea,
        );
        if (attackEffectBottomAnim != null) anim = attackEffectBottomAnim;
        break;
      case Direction.left:
        positionAttack = Rect.fromLTWH(
          this.positionInWorld.left - this.width,
          this.positionInWorld.top + (this.height - heightArea) / 2,
          widthArea,
          heightArea,
        );
        if (attackEffectLeftAnim != null) anim = attackEffectLeftAnim;
        break;
    }

    gameRef.add(AnimatedObjectOnce(animation: anim, position: positionAttack));

    player.receiveDamage(damage);
  }

  void simpleAttackRange({
    @required FlameAnimation.Animation animationRight,
    @required FlameAnimation.Animation animationLeft,
    @required FlameAnimation.Animation animationTop,
    @required FlameAnimation.Animation animationBottom,
    @required FlameAnimation.Animation animationDestroy,
    @required double width,
    @required double height,
    double speed = 1.5,
    double damage = 1,
    Direction direction,
    int interval = 1000,
  }) {
    if (!this.checkPassedInterval('attackRange', interval)) return;

    Player player = this.gameRef.player;

    if (player.isDead || !isVisibleInMap() || isDead) return;

    Position startPosition;
    FlameAnimation.Animation attackRangeAnimation;

    Direction ballDirection;

    var diffX = position.center.dx - player.position.center.dx;
    var diffPositiveX = diffX < 0 ? diffX *= -1 : diffX;
    var diffY = position.center.dy - player.position.center.dy;
    var diffPositiveY = diffY < 0 ? diffY *= -1 : diffY;

    if (diffPositiveX > diffPositiveY) {
      if (player.position.center.dx > position.center.dx) {
        ballDirection = Direction.right;
      } else if (player.position.center.dx < position.center.dx) {
        ballDirection = Direction.left;
      }
    } else {
      if (player.position.center.dy > position.center.dy) {
        ballDirection = Direction.bottom;
      } else if (player.position.center.dy < position.center.dy) {
        ballDirection = Direction.top;
      }
    }

    Direction finalDirection = direction != null ? direction : ballDirection;

    switch (finalDirection) {
      case Direction.left:
        if (animationLeft != null) attackRangeAnimation = animationLeft;
        startPosition = Position(
          this.positionInWorld.left - width,
          (this.positionInWorld.top +
              (this.positionInWorld.height - height) / 2),
        );
        break;
      case Direction.right:
        if (animationRight != null) attackRangeAnimation = animationRight;
        startPosition = Position(
          this.positionInWorld.right,
          (this.positionInWorld.top +
              (this.positionInWorld.height - height) / 2),
        );
        break;
      case Direction.top:
        if (animationTop != null) attackRangeAnimation = animationTop;
        startPosition = Position(
          (this.positionInWorld.left +
              (this.positionInWorld.width - width) / 2),
          this.positionInWorld.top - height,
        );
        break;
      case Direction.bottom:
        if (animationBottom != null) attackRangeAnimation = animationBottom;
        startPosition = Position(
          (this.positionInWorld.left +
              (this.positionInWorld.width - width) / 2),
          this.positionInWorld.bottom,
        );
        break;
    }

    this.lastDirection = finalDirection;
    if (finalDirection == Direction.right || finalDirection == Direction.left) {
      this.lastDirectionHorizontal = finalDirection;
    }

    gameRef.add(
      FlyingAttackObject(
        direction: finalDirection,
        flyAnimation: attackRangeAnimation,
        destroyAnimation: animationDestroy,
        initPosition: startPosition,
        height: height,
        width: width,
        damage: damage,
        speed: speed,
        damageInEnemy: false,
      ),
    );
  }

  void seeAndMoveToAttackRange(
      {Function(Player) positioned, int visionCells = 5}) {
    if (!isVisibleInMap() || isDead) return;

    seePlayer(
        visionCells: visionCells,
        observed: (player) {
          double centerXPlayer = player.position.center.dx;
          double centerYPlayer = player.position.center.dy;

          double translateX = 0;
          double translateY = 0;

          translateX =
              position.center.dx > centerXPlayer ? (-1 * speed) : speed;
          translateX = _adjustTranslate(
            translateX,
            position.center.dx,
            centerXPlayer,
          );

          translateY =
              position.center.dy > centerYPlayer ? (-1 * speed) : speed;
          translateY = _adjustTranslate(
            translateY,
            position.center.dy,
            centerYPlayer,
          );

          if ((translateX < 0 && translateX > -0.1) ||
              (translateX > 0 && translateX < 0.1)) {
            translateX = 0;
          }

          if ((translateY < 0 && translateY > -0.1) ||
              (translateY > 0 && translateY < 0.1)) {
            translateY = 0;
          }

          if (translateX == 0 && translateY == 0) {
            idle();
            return;
          }

          double translateXPositive =
              this.position.center.dx - player.position.center.dx;
          translateXPositive = translateXPositive >= 0
              ? translateXPositive
              : translateXPositive * -1;
          double translateYPositive =
              this.position.center.dy - player.position.center.dy;
          translateYPositive = translateYPositive >= 0
              ? translateYPositive
              : translateYPositive * -1;

          if (translateXPositive > translateYPositive) {
            if (translateY > 0) {
              moveBottom(moveSpeed: translateY);
            } else if (translateY < 0) {
              moveTop(moveSpeed: (translateY * -1));
            } else {
              positioned(player);
              this.idle();
            }
          } else {
            if (translateX > 0) {
              moveRight(moveSpeed: translateX);
            } else if (translateX < 0) {
              moveLeft(moveSpeed: (translateX * -1));
            } else {
              positioned(player);
              this.idle();
            }
          }
        },
        notObserved: () {
          this.idle();
        });
  }

  double _adjustTranslate(
      double translate, double centerEnemy, double centerPlayer) {
    double innerTranslate = translate;
    if (innerTranslate > 0) {
      double diffX = centerPlayer - centerEnemy;
      if (diffX < this.speed) {
        innerTranslate = diffX;
      }
    } else if (innerTranslate < 0) {
      double diffX = centerPlayer - centerEnemy;
      if (diffX > (this.speed * -1)) {
        innerTranslate = diffX;
      }
    }

    return innerTranslate;
  }

  Direction directionThatPlayerIs() {
    Player player = this.gameRef.player;
    var diffX = position.center.dx - player.position.center.dx;
    var diffPositiveX = diffX < 0 ? diffX *= -1 : diffX;
    var diffY = position.center.dy - player.position.center.dy;
    var diffPositiveY = diffY < 0 ? diffY *= -1 : diffY;

    if (diffPositiveX > diffPositiveY) {
      if (player.position.center.dx > position.center.dx) {
        return Direction.right;
      } else if (player.position.center.dx < position.center.dx) {
        return Direction.left;
      }
    } else {
      if (player.position.center.dy > position.center.dy) {
        return Direction.bottom;
      } else if (player.position.center.dy < position.center.dy) {
        return Direction.top;
      }
    }

    return Direction.left;
  }

  void showDamage(double damage,
      {TextConfig config = const TextConfig(
        fontSize: 10,
        color: Colors.white,
      )}) {
    gameRef.add(
      TextDamage(
        damage.toInt().toString(),
        Position(
          positionInWorld.center.dx,
          positionInWorld.top,
        ),
        config: config,
      ),
    );
  }

  void drawDefaultLifeBar(
    Canvas canvas, {
    bool drawInBottom = false,
    double padding = 5,
    double strokeWidth = 2,
  }) {
    double yPosition = position.top - padding;

    if (drawInBottom) {
      yPosition = position.bottom + padding;
    }

    canvas.drawLine(
        Offset(position.left, yPosition),
        Offset(position.left + position.width, yPosition),
        Paint()
          ..color = Colors.black
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.fill);

    double currentBarLife = (life * position.width) / maxLife;

    canvas.drawLine(
        Offset(position.left, yPosition),
        Offset(position.left + currentBarLife, yPosition),
        Paint()
          ..color = _getColorLife(currentBarLife)
          ..strokeWidth = strokeWidth
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
}
