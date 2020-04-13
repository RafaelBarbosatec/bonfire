import 'dart:ui';

import 'package:bonfire/enemy/enemy.dart';
import 'package:bonfire/player/player.dart';
import 'package:bonfire/util/collision/collision.dart';
import 'package:bonfire/util/direction.dart';
import 'package:bonfire/util/objects/animated_object_once.dart';
import 'package:bonfire/util/objects/flying_attack_object.dart';
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

    double visionWidth = this.position.width * visionCells * 2;
    double visionHeight = this.position.height * visionCells * 2;

    Rect fieldOfVision = Rect.fromLTWH(
      this.position.left - (visionWidth / 2),
      this.position.top - (visionHeight / 2),
      visionWidth,
      visionHeight,
    );

    if (fieldOfVision.overlaps(player.rectCollision)) {
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
        double centerXPlayer = player.rectCollision.center.dx;
        double centerYPlayer = player.rectCollision.center.dy;

        double translateX = 0;
        double translateY = 0;

        translateX =
            this.position.center.dx > centerXPlayer ? (-1 * speed) : speed;
        translateX = _adjustTranslate(
          translateX,
          this.position.center.dx,
          centerXPlayer,
        );
        translateY =
            this.position.center.dy > centerYPlayer ? (-1 * speed) : speed;
        translateY = _adjustTranslate(
          translateY,
          this.position.center.dy,
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

        if (this.position.overlaps(player.rectCollision)) {
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
    bool withPush = false,
    FlameAnimation.Animation attackEffectRightAnim,
    FlameAnimation.Animation attackEffectBottomAnim,
    FlameAnimation.Animation attackEffectLeftAnim,
    FlameAnimation.Animation attackEffectTopAnim,
    VoidCallback execute,
  }) {
    if (!this.checkPassedInterval('attackMelee', interval)) return;

    Player player = gameRef.player;

    if (player.isDead || !isVisibleInMap() || isDead) return;

    Rect positionAttack;
    FlameAnimation.Animation anim = attackEffectRightAnim;

    Direction playerDirection;

    double centerXPlayer = player.rectCollision.center.dx;
    double centerYPlayer = player.rectCollision.center.dy;

    double centerYEnemy = rectCollision.center.dy;
    double centerXEnemy = rectCollision.center.dx;

    double diffX = centerXEnemy - centerXPlayer;
    double diffY = centerYEnemy - centerYPlayer;

    double positiveDiffX = diffX > 0 ? diffX : diffX * -1;
    double positiveDiffY = diffY > 0 ? diffY : diffY * -1;
    if (positiveDiffX > positiveDiffY) {
      playerDirection = diffX > 0 ? Direction.left : Direction.right;
    } else {
      playerDirection = diffY > 0 ? Direction.top : Direction.bottom;
    }

    double pushLeft = 0;
    double pushTop = 0;
    switch (playerDirection) {
      case Direction.top:
        positionAttack = Rect.fromLTWH(
          this.positionInWorld.left + (this.width - widthArea) / 2,
          this.positionInWorld.top - this.height,
          widthArea,
          heightArea,
        );
        if (attackEffectTopAnim != null) anim = attackEffectTopAnim;
        pushTop = heightArea * -1;
        break;
      case Direction.right:
        positionAttack = Rect.fromLTWH(
          this.positionInWorld.right,
          this.positionInWorld.top + (this.height - heightArea) / 2,
          widthArea,
          heightArea,
        );
        if (attackEffectRightAnim != null) anim = attackEffectRightAnim;
        pushLeft = widthArea;
        break;
      case Direction.bottom:
        positionAttack = Rect.fromLTWH(
          this.positionInWorld.left + (this.width - widthArea) / 2,
          this.positionInWorld.bottom,
          widthArea,
          heightArea,
        );
        if (attackEffectBottomAnim != null) anim = attackEffectBottomAnim;
        pushTop = heightArea;
        break;
      case Direction.left:
        positionAttack = Rect.fromLTWH(
          this.positionInWorld.left - this.width,
          this.positionInWorld.top + (this.height - heightArea) / 2,
          widthArea,
          heightArea,
        );
        if (attackEffectLeftAnim != null) anim = attackEffectLeftAnim;
        pushLeft = widthArea * -1;
        break;
    }

    gameRef.add(AnimatedObjectOnce(animation: anim, position: positionAttack));

    player.receiveDamage(damage);
    Rect rectAfterPush = player.position.translate(pushLeft, pushTop);
    if (withPush && !player.isCollision(rectAfterPush, this.gameRef)) {
      player.position = rectAfterPush;
    }

    if (execute != null) execute();
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
    bool withCollision = true,
    Collision collision,
    VoidCallback destroy,
    VoidCallback execute,
  }) {
    if (!this.checkPassedInterval('attackRange', interval)) return;

    Player player = this.gameRef.player;

    if (player.isDead || !isVisibleInMap() || isDead) return;

    Position startPosition;
    FlameAnimation.Animation attackRangeAnimation;

    Direction ballDirection;

    var diffX = this.rectCollision.center.dx - player.rectCollision.center.dx;
    var diffPositiveX = diffX < 0 ? diffX *= -1 : diffX;
    var diffY = this.rectCollision.center.dy - player.rectCollision.center.dy;
    var diffPositiveY = diffY < 0 ? diffY *= -1 : diffY;

    if (diffPositiveX > diffPositiveY) {
      if (player.rectCollision.center.dx > this.rectCollision.center.dx) {
        ballDirection = Direction.right;
      } else if (player.rectCollision.center.dx <
          this.rectCollision.center.dx) {
        ballDirection = Direction.left;
      }
    } else {
      if (player.rectCollision.center.dy > rectCollision.center.dy) {
        ballDirection = Direction.bottom;
      } else if (player.rectCollision.center.dy < rectCollision.center.dy) {
        ballDirection = Direction.top;
      }
    }

    Direction finalDirection = direction != null ? direction : ballDirection;

    switch (finalDirection) {
      case Direction.left:
        if (animationLeft != null) attackRangeAnimation = animationLeft;
        startPosition = Position(
          this.rectCollisionInWorld.left - width,
          (this.rectCollisionInWorld.top +
              (this.rectCollisionInWorld.height - height) / 2),
        );
        break;
      case Direction.right:
        if (animationRight != null) attackRangeAnimation = animationRight;
        startPosition = Position(
          this.rectCollisionInWorld.right,
          (this.rectCollisionInWorld.top +
              (this.rectCollisionInWorld.height - height) / 2),
        );
        break;
      case Direction.top:
        if (animationTop != null) attackRangeAnimation = animationTop;
        startPosition = Position(
          (this.rectCollisionInWorld.left +
              (this.rectCollisionInWorld.width - width) / 2),
          this.rectCollisionInWorld.top - height,
        );
        break;
      case Direction.bottom:
        if (animationBottom != null) attackRangeAnimation = animationBottom;
        startPosition = Position(
          (this.rectCollisionInWorld.left +
              (this.rectCollisionInWorld.width - width) / 2),
          this.rectCollisionInWorld.bottom,
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
        destroyedObject: destroy,
        withCollision: withCollision,
        collision: collision ??
            Collision(
              width: width / 1.5,
              height: height / 2,
              align: CollisionAlign.CENTER,
            ),
      ),
    );

    if (execute != null) execute();
  }

  void seeAndMoveToAttackRange(
      {Function(Player) positioned, int visionCells = 5}) {
    if (!isVisibleInMap() || isDead) return;

    seePlayer(
      visionCells: visionCells,
      observed: (player) {
        double centerXPlayer = player.rectCollision.center.dx;
        double centerYPlayer = player.rectCollision.center.dy;

        double translateX = 0;
        double translateY = 0;

        translateX =
            rectCollision.center.dx > centerXPlayer ? (-1 * speed) : speed;
        translateX = _adjustTranslate(
          translateX,
          rectCollision.center.dx,
          centerXPlayer,
        );

        translateY =
            rectCollision.center.dy > centerYPlayer ? (-1 * speed) : speed;
        translateY = _adjustTranslate(
          translateY,
          rectCollision.center.dy,
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
            this.rectCollision.center.dx - player.rectCollision.center.dx;
        translateXPositive = translateXPositive >= 0
            ? translateXPositive
            : translateXPositive * -1;
        double translateYPositive =
            this.rectCollision.center.dy - player.rectCollision.center.dy;
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
      },
    );
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

  void drawPositionCollision(Canvas canvas) {
    this.drawCollision(canvas, position);
  }
}
