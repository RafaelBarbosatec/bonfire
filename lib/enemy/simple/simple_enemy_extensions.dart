import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/enemy/extensions.dart';
import 'package:bonfire/enemy/simple/simple_enemy.dart';
import 'package:bonfire/lighting/lighting_config.dart';
import 'package:bonfire/objects/animated_object_once.dart';
import 'package:bonfire/objects/flying_attack_object.dart';
import 'package:bonfire/player/player.dart';
import 'package:bonfire/util/collision/object_collision.dart';
import 'package:bonfire/util/direction.dart';
import 'package:bonfire/util/vector2rect.dart';
import 'package:flame/components.dart';
import 'package:flutter/widgets.dart';

extension SimpleEnemyExtensions on SimpleEnemy {
  void seeAndMoveToPlayer({
    Function(Player) closePlayer,
    double radiusVision = 32,
    double margin = 10,
  }) {
    if (isDead || this.position == null) return;
    if (this is ObjectCollision &&
        (this as ObjectCollision).notVisibleAndCollisionOnlyScreen()) return;

    seePlayer(
      radiusVision: radiusVision,
      observed: (player) {
        double centerXPlayer = playerRect.center.dx;
        double centerYPlayer = playerRect.center.dy;

        double translateX = 0;
        double translateY = 0;
        double speed = this.speed * this.dtUpdate;

        Vector2Rect rectToMove = this is ObjectCollision
            ? (this as ObjectCollision).rectCollision
            : position;

        translateX =
            rectToMove.rect.center.dx > centerXPlayer ? (-1 * speed) : speed;

        translateX = _adjustTranslate(
          translateX,
          rectToMove.rect.center.dx,
          centerXPlayer,
          speed,
        );
        translateY =
            rectToMove.rect.center.dy > centerYPlayer ? (-1 * speed) : speed;
        translateY = _adjustTranslate(
          translateY,
          rectToMove.rect.center.dy,
          centerYPlayer,
          speed,
        );

        if ((translateX < 0 && translateX > -0.1) ||
            (translateX > 0 && translateX < 0.1)) {
          translateX = 0;
        }

        if ((translateY < 0 && translateY > -0.1) ||
            (translateY > 0 && translateY < 0.1)) {
          translateY = 0;
        }

        Rect rectPlayerCollision = Rect.fromLTWH(
          playerRect.left - margin,
          playerRect.top - margin,
          playerRect.width + (margin * 2),
          playerRect.height + (margin * 2),
        );

        if (rectToMove.rect.overlaps(rectPlayerCollision)) {
          if (closePlayer != null) closePlayer(player);
          this.idle();
          return;
        }

        if (translateX > 0 && translateY > 0) {
          this.customMoveBottomRight(translateX, translateY);
        } else if (translateX < 0 && translateY < 0) {
          this.customMoveTopLeft(translateX * -1, translateY * -1);
        } else if (translateX > 0 && translateY < 0) {
          this.customMoveTopRight(translateX, translateY * -1);
        } else if (translateX < 0 && translateY > 0) {
          this.customMoveBottomLeft(translateX * -1, translateY);
        } else {
          if (translateX > 0) {
            this.customMoveRight(translateX);
          } else if (translateX < 0) {
            customMoveLeft((translateX * -1));
          }
          if (translateY > 0) {
            customMoveBottom(translateY);
          } else if (translateY < 0) {
            customMoveTop((translateY * -1));
          }
        }
      },
      notObserved: () {
        this.idle();
      },
    );
  }

  void simpleAttackMelee({
    @required double damage,
    double heightArea = 32,
    double widthArea = 32,
    int id,
    int interval = 1000,
    bool withPush = false,
    double sizePush,
    Direction direction,
    SpriteAnimation attackEffectRightAnim,
    SpriteAnimation attackEffectBottomAnim,
    SpriteAnimation attackEffectLeftAnim,
    SpriteAnimation attackEffectTopAnim,
    VoidCallback execute,
  }) {
    if (!this.checkPassedInterval('attackMelee', interval, dtUpdate)) return;

    if (isDead || this.position == null) return;

    Rect positionAttack;
    SpriteAnimation anim;

    Direction playerDirection;

    Vector2Rect rectToMove = this is ObjectCollision
        ? (this as ObjectCollision).rectCollision
        : position;

    if (direction == null) {
      double centerXPlayer = playerRect.center.dx;
      double centerYPlayer = playerRect.center.dy;

      double centerYEnemy = rectToMove.rect.center.dy;
      double centerXEnemy = rectToMove.rect.center.dx;

      double diffX = centerXEnemy - centerXPlayer;
      double diffY = centerYEnemy - centerYPlayer;

      double positiveDiffX = diffX > 0 ? diffX : diffX * -1;
      double positiveDiffY = diffY > 0 ? diffY : diffY * -1;
      if (positiveDiffX > positiveDiffY) {
        playerDirection = diffX > 0 ? Direction.left : Direction.right;
      } else {
        playerDirection = diffY > 0 ? Direction.top : Direction.bottom;
      }
    } else {
      playerDirection = direction;
    }

    double pushLeft = 0;
    double pushTop = 0;
    switch (playerDirection) {
      case Direction.top:
        positionAttack = Rect.fromLTWH(
          this.position.rect.left + (this.width - widthArea) / 2,
          rectToMove.rect.top - heightArea,
          widthArea,
          heightArea,
        );
        if (attackEffectTopAnim != null) anim = attackEffectTopAnim;
        pushTop = (sizePush ?? heightArea) * -1;
        break;
      case Direction.right:
        positionAttack = Rect.fromLTWH(
          rectToMove.rect.right,
          this.position.rect.top + (this.height - heightArea) / 2,
          widthArea,
          heightArea,
        );
        if (attackEffectRightAnim != null) anim = attackEffectRightAnim;
        pushLeft = (sizePush ?? widthArea);
        break;
      case Direction.bottom:
        positionAttack = Rect.fromLTWH(
          this.position.rect.left + (this.width - widthArea) / 2,
          rectToMove.rect.bottom,
          widthArea,
          heightArea,
        );
        if (attackEffectBottomAnim != null) anim = attackEffectBottomAnim;
        pushTop = (sizePush ?? heightArea);
        break;
      case Direction.left:
        positionAttack = Rect.fromLTWH(
          rectToMove.rect.left - widthArea,
          this.position.rect.top + (this.height - heightArea) / 2,
          widthArea,
          heightArea,
        );
        if (attackEffectLeftAnim != null) anim = attackEffectLeftAnim;
        pushLeft = (sizePush ?? widthArea) * -1;
        break;
      case Direction.topLeft:
        positionAttack = Rect.fromLTWH(
          rectToMove.rect.left - widthArea,
          this.position.rect.top + (this.height - heightArea) / 2,
          widthArea,
          heightArea,
        );
        if (attackEffectLeftAnim != null) anim = attackEffectLeftAnim;
        pushLeft = (sizePush ?? widthArea) * -1;
        break;
      case Direction.topRight:
        positionAttack = Rect.fromLTWH(
          rectToMove.rect.right,
          this.position.rect.top + (this.height - heightArea) / 2,
          widthArea,
          heightArea,
        );
        if (attackEffectRightAnim != null) anim = attackEffectRightAnim;
        pushLeft = (sizePush ?? widthArea);
        break;
      case Direction.bottomLeft:
        positionAttack = Rect.fromLTWH(
          rectToMove.rect.left - widthArea,
          this.position.rect.top + (this.height - heightArea) / 2,
          widthArea,
          heightArea,
        );
        if (attackEffectLeftAnim != null) anim = attackEffectLeftAnim;
        pushLeft = (sizePush ?? widthArea) * -1;
        break;
      case Direction.bottomRight:
        positionAttack = Rect.fromLTWH(
          rectToMove.rect.right,
          this.position.rect.top + (this.height - heightArea) / 2,
          widthArea,
          heightArea,
        );
        if (attackEffectRightAnim != null) anim = attackEffectRightAnim;
        pushLeft = (sizePush ?? widthArea);
        break;
    }

    if (anim != null) {
      gameRef.addLater(
        AnimatedObjectOnce(animation: anim, position: positionAttack),
      );
    }

    gameRef
        .attackables()
        .where((a) =>
            a.receivesAttackFromEnemy() &&
            a.rectAttackable().rect.overlaps(positionAttack))
        .forEach((attackable) {
      attackable.receiveDamage(damage, id);
      Vector2Rect rectAfterPush =
          attackable.position.translate(pushLeft, pushTop);
      if (withPush &&
          (attackable is ObjectCollision &&
              !(attackable as ObjectCollision)
                  .isCollision(displacement: rectAfterPush.rect))) {
        attackable.position = rectAfterPush;
      }
    });

    if (execute != null) execute();
  }

  void simpleAttackRange({
    @required SpriteAnimation animationRight,
    @required SpriteAnimation animationLeft,
    @required SpriteAnimation animationTop,
    @required SpriteAnimation animationBottom,
    @required SpriteAnimation animationDestroy,
    @required double width,
    @required double height,
    int id,
    double speed = 150,
    double damage = 1,
    Direction direction,
    int interval = 1000,
    bool withCollision = true,
    CollisionConfig collision,
    VoidCallback destroy,
    VoidCallback execute,
    LightingConfig lightingConfig,
  }) {
    if (!this.checkPassedInterval('attackRange', interval, dtUpdate)) return;

    if (isDead) return;

    Vector2 startPosition;
    SpriteAnimation attackRangeAnimation;

    Direction ballDirection;

    Vector2Rect rectToMove = this is ObjectCollision
        ? (this as ObjectCollision).rectCollision
        : position;

    var diffX = rectToMove.rect.center.dx - playerRect.center.dx;
    var diffPositiveX = diffX < 0 ? diffX *= -1 : diffX;
    var diffY = rectToMove.rect.center.dy - playerRect.center.dy;
    var diffPositiveY = diffY < 0 ? diffY *= -1 : diffY;

    if (diffPositiveX > diffPositiveY) {
      if (playerRect.center.dx > rectToMove.rect.center.dx) {
        ballDirection = Direction.right;
      } else if (playerRect.center.dx < rectToMove.rect.center.dx) {
        ballDirection = Direction.left;
      }
    } else {
      if (playerRect.center.dy > rectToMove.rect.center.dy) {
        ballDirection = Direction.bottom;
      } else if (playerRect.center.dy < rectToMove.rect.center.dy) {
        ballDirection = Direction.top;
      }
    }

    Direction finalDirection = direction != null ? direction : ballDirection;

    switch (finalDirection) {
      case Direction.left:
        if (animationLeft != null) attackRangeAnimation = animationLeft;
        startPosition = Vector2(
          rectToMove.rect.left - width,
          (rectToMove.rect.top + (rectToMove.rect.height - height) / 2),
        );
        break;
      case Direction.right:
        if (animationRight != null) attackRangeAnimation = animationRight;
        startPosition = Vector2(
          rectToMove.rect.right,
          (rectToMove.rect.top + (rectToMove.rect.height - height) / 2),
        );
        break;
      case Direction.top:
        if (animationTop != null) attackRangeAnimation = animationTop;
        startPosition = Vector2(
          (rectToMove.rect.left + (rectToMove.rect.width - width) / 2),
          rectToMove.rect.top - height,
        );
        break;
      case Direction.bottom:
        if (animationBottom != null) attackRangeAnimation = animationBottom;
        startPosition = Vector2(
          (rectToMove.rect.left + (rectToMove.rect.width - width) / 2),
          rectToMove.rect.bottom,
        );
        break;
      case Direction.topLeft:
        if (animationLeft != null) attackRangeAnimation = animationLeft;
        startPosition = Vector2(
          rectToMove.rect.left - width,
          (rectToMove.rect.top + (rectToMove.rect.height - height) / 2),
        );
        break;
      case Direction.topRight:
        if (animationRight != null) attackRangeAnimation = animationRight;
        startPosition = Vector2(
          rectToMove.rect.right,
          (rectToMove.rect.top + (rectToMove.rect.height - height) / 2),
        );
        break;
      case Direction.bottomLeft:
        if (animationLeft != null) attackRangeAnimation = animationLeft;
        startPosition = Vector2(
          rectToMove.rect.left - width,
          (rectToMove.rect.top + (rectToMove.rect.height - height) / 2),
        );
        break;
      case Direction.bottomRight:
        if (animationRight != null) attackRangeAnimation = animationRight;
        startPosition = Vector2(
          rectToMove.rect.right,
          (rectToMove.rect.top + (rectToMove.rect.height - height) / 2),
        );
        break;
    }

    this.lastDirection = finalDirection;
    if (finalDirection == Direction.right || finalDirection == Direction.left) {
      this.lastDirectionHorizontal = finalDirection;
    }

    gameRef.addLater(
      FlyingAttackObject(
        id: id,
        direction: finalDirection,
        flyAnimation: attackRangeAnimation,
        destroyAnimation: animationDestroy,
        initPosition: startPosition,
        height: height,
        width: width,
        damage: damage,
        speed: speed,
        destroyedObject: destroy,
        withDecorationCollision: withCollision,
        collision: collision,
        lightingConfig: lightingConfig,
      ),
    );

    if (execute != null) execute();
  }

  void seeAndMoveToAttackRange(
      {Function(Player) positioned,
      double radiusVision = 32,
      double minDistanceFromPlayer}) {
    if (isDead || this.position == null) return;
    if (this is ObjectCollision &&
        (this as ObjectCollision).notVisibleAndCollisionOnlyScreen()) return;

    double distance = (minDistanceFromPlayer ?? radiusVision);

    seePlayer(
      radiusVision: radiusVision,
      observed: (player) {
        double centerXPlayer = playerRect.center.dx;
        double centerYPlayer = playerRect.center.dy;

        double translateX = 0;
        double translateY = 0;

        double speed = this.speed * this.dtUpdate;

        Vector2Rect rectToMove = this is ObjectCollision
            ? (this as ObjectCollision).rectCollision
            : position;

        translateX =
            rectToMove.rect.center.dx > centerXPlayer ? (-1 * speed) : speed;
        translateX = _adjustTranslate(
          translateX,
          rectToMove.rect.center.dx,
          centerXPlayer,
          speed,
        );

        translateY =
            rectToMove.rect.center.dy > centerYPlayer ? (-1 * speed) : speed;
        translateY = _adjustTranslate(
          translateY,
          rectToMove.rect.center.dy,
          centerYPlayer,
          speed,
        );

        if ((translateX < 0 && translateX > -0.1) ||
            (translateX > 0 && translateX < 0.1)) {
          translateX = 0;
        }

        if ((translateY < 0 && translateY > -0.1) ||
            (translateY > 0 && translateY < 0.1)) {
          translateY = 0;
        }

        double translateXPositive =
            rectToMove.rect.center.dx - playerRect.center.dx;
        translateXPositive = translateXPositive >= 0
            ? translateXPositive
            : translateXPositive * -1;

        double translateYPositive =
            rectToMove.rect.center.dy - playerRect.center.dy;
        translateYPositive = translateYPositive >= 0
            ? translateYPositive
            : translateYPositive * -1;

        if (translateXPositive >= distance &&
            translateXPositive > translateYPositive) {
          translateX = 0;
        } else if (translateXPositive > translateYPositive) {
          translateX = translateX * -1;
          positioned(player);
        }

        if (translateYPositive >= distance &&
            translateXPositive < translateYPositive) {
          translateY = 0;
        } else if (translateXPositive < translateYPositive) {
          translateY = translateY * -1;
          positioned(player);
        }

        if (translateX == 0 && translateY == 0) {
          idle();
          positioned(player);
          return;
        }

        if (translateX > 0 && translateY > 0) {
          this.customMoveBottomRight(translateX, translateY);
        } else if (translateX < 0 && translateY < 0) {
          this.customMoveTopLeft(translateX * -1, translateY * -1);
        } else if (translateX > 0 && translateY < 0) {
          this.customMoveTopRight(translateX, translateY * -1);
        } else if (translateX < 0 && translateY > 0) {
          this.customMoveBottomLeft(translateX * -1, translateY);
        } else {
          if (translateX > 0) {
            this.customMoveRight(translateX);
          } else {
            customMoveLeft((translateX * -1));
          }
          if (translateY > 0) {
            customMoveBottom(translateY);
          } else {
            customMoveTop((translateY * -1));
          }
        }
      },
      notObserved: () {
        this.idle();
      },
    );
  }

  double _adjustTranslate(
    double translate,
    double centerEnemy,
    double centerPlayer,
    double speed,
  ) {
    double innerTranslate = translate;
    if (innerTranslate > 0) {
      double diffX = centerPlayer - centerEnemy;
      if (diffX < speed) {
        innerTranslate = diffX;
      }
    } else if (innerTranslate < 0) {
      double diffX = centerPlayer - centerEnemy;
      if (diffX > (speed * -1)) {
        innerTranslate = diffX;
      }
    }

    return innerTranslate;
  }
}
