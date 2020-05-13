import 'package:bonfire/player/simple_player.dart';
import 'package:bonfire/util/collision/collision.dart';
import 'package:bonfire/util/direction.dart';
import 'package:bonfire/util/objects/animated_object_once.dart';
import 'package:bonfire/util/objects/flying_attack_object.dart';
import 'package:flame/animation.dart' as FlameAnimation;
import 'package:flame/position.dart';
import 'package:flutter/widgets.dart';

extension SimplePlayerExtensions on SimplePlayer {
  void simpleAttackMelee({
    @required FlameAnimation.Animation attackEffectRightAnim,
    @required FlameAnimation.Animation attackEffectBottomAnim,
    @required FlameAnimation.Animation attackEffectLeftAnim,
    @required FlameAnimation.Animation attackEffectTopAnim,
    @required double damage,
    int id,
    Direction direction,
    double heightArea = 32,
    double widthArea = 32,
    bool withPush = true,
  }) {
    if (isDead) return;

    Rect positionAttack;
    FlameAnimation.Animation anim = attackEffectRightAnim;
    double pushLeft = 0;
    double pushTop = 0;

    Direction attackDirection = direction ?? this.lastDirection;
    switch (attackDirection) {
      case Direction.top:
        positionAttack = Rect.fromLTWH(positionInWorld.left,
            positionInWorld.top - heightArea, widthArea, heightArea);
        if (attackEffectTopAnim != null) anim = attackEffectTopAnim;
        pushTop = heightArea * -1;
        break;
      case Direction.right:
        positionAttack = Rect.fromLTWH(positionInWorld.left + widthArea,
            positionInWorld.top, widthArea, heightArea);
        if (attackEffectRightAnim != null) anim = attackEffectRightAnim;
        pushLeft = widthArea;
        break;
      case Direction.bottom:
        positionAttack = Rect.fromLTWH(positionInWorld.left,
            positionInWorld.top + heightArea, widthArea, heightArea);
        if (attackEffectBottomAnim != null) anim = attackEffectBottomAnim;
        pushTop = heightArea;
        break;
      case Direction.left:
        positionAttack = Rect.fromLTWH(positionInWorld.left - widthArea,
            positionInWorld.top, widthArea, heightArea);
        if (attackEffectLeftAnim != null) anim = attackEffectLeftAnim;
        pushLeft = widthArea * -1;
        break;
    }

    gameRef.add(AnimatedObjectOnce(animation: anim, position: positionAttack));

    gameRef.visibleEnemies().forEach((enemy) {
      if (enemy.rectCollisionInWorld.overlaps(positionAttack)) {
        enemy.receiveDamage(damage, id);
        Rect rectAfterPush = enemy.position.translate(pushLeft, pushTop);
        if (withPush && !enemy.isCollision(rectAfterPush, this.gameRef)) {
          enemy.translate(pushLeft, pushTop);
        }
      }
    });
  }

  void simpleAttackRange({
    @required FlameAnimation.Animation animationRight,
    @required FlameAnimation.Animation animationLeft,
    @required FlameAnimation.Animation animationTop,
    @required FlameAnimation.Animation animationBottom,
    @required FlameAnimation.Animation animationDestroy,
    @required double width,
    @required double height,
    int id,
    double speed = 150,
    double damage = 1,
    Direction direction,
    bool withCollision = true,
    VoidCallback destroy,
    Collision collision,
  }) {
    if (isDead) return;

    Position startPosition;
    FlameAnimation.Animation attackRangeAnimation;

    Direction attackDirection = direction ?? this.lastDirection;

    switch (attackDirection) {
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

    gameRef.add(
      FlyingAttackObject(
        id: id,
        direction: attackDirection,
        flyAnimation: attackRangeAnimation,
        destroyAnimation: animationDestroy,
        initPosition: startPosition,
        height: height,
        width: width,
        damage: damage,
        speed: speed,
        damageInPlayer: false,
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
  }
}
