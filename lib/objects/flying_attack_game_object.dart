import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:flutter/widgets.dart';

/// Animated component used like range attack.
class FlyingAttackGameObject extends AnimatedGameObject
    with Movement, CanNotSeen {
  final dynamic id;
  Future<SpriteAnimation>? animationDestroy;

  final double damage;
  final AttackOriginEnum attackFrom;
  final bool withDecorationCollision;
  final VoidCallback? onDestroy;
  final bool enabledDiagonal;
  final Vector2? destroySize;
  double _cosAngle = 0;
  double _senAngle = 0;
  ShapeHitbox? shapeCollision;

  final IntervalTick _intervalTick = IntervalTick(
    1000,
  );

  FlyingAttackGameObject({
    required super.position,
    required super.size,
    required super.animation,
    super.angle = 0,
    Direction? direction,
    this.id,
    this.animationDestroy,
    this.destroySize,
    double speed = 150,
    this.damage = 1,
    this.attackFrom = AttackOriginEnum.ENEMY,
    this.withDecorationCollision = true,
    this.onDestroy,
    this.enabledDiagonal = true,
    super.lightingConfig,
    this.shapeCollision,
  }) {
    this.speed = speed;

    _cosAngle = cos(angle);
    _senAngle = sin(angle);

    if (direction != null) {
      moveFromDirection(direction, useDiagonal: enabledDiagonal);
    } else {
      moveByAngle(angle);
    }
  }

  FlyingAttackGameObject.byDirection({
    required super.position,
    required super.size,
    required super.animation,
    Direction? direction,
    this.id,
    this.animationDestroy,
    this.destroySize,
    double speed = 150,
    this.damage = 1,
    this.attackFrom = AttackOriginEnum.ENEMY,
    this.withDecorationCollision = true,
    this.onDestroy,
    this.enabledDiagonal = true,
    super.lightingConfig,
    this.shapeCollision,
  }) {
    this.speed = speed;
    moveFromDirection(direction!, useDiagonal: enabledDiagonal);
  }

  FlyingAttackGameObject.byAngle({
    required super.position,
    required super.size,
    required super.animation,
    required super.angle,
    this.id,
    this.animationDestroy,
    this.destroySize,
    double speed = 150,
    this.damage = 1,
    this.attackFrom = AttackOriginEnum.ENEMY,
    this.withDecorationCollision = true,
    this.onDestroy,
    this.enabledDiagonal = true,
    super.lightingConfig,
    this.shapeCollision,
  }) {
    this.speed = speed;

    _cosAngle = cos(angle);
    _senAngle = sin(angle);

    moveByAngle(angle);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _verifyExistInWorld(dt);
  }

  @override
  bool onComponentTypeCheck(PositionComponent other) {
    if (other is WithSensor) {
      return false;
    }

    if (!withDecorationCollision && other is GameDecoration) {
      return false;
    }

    return super.onComponentTypeCheck(other);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (isRemoving || isRemoved) {
      return;
    }
    if (other is WithLife) {
      if (!other.life.checkCanReceiveDamage(attackFrom)) {
        return;
      }

      // When there is an explosion (animationDestroy), the damage is applied
      // by the explosion DamageHitbox created in [_destroyByAngle]. Applying
      // it here too would hit the target twice.
      if (animationDestroy == null) {
        other.life.handleAttack(attackFrom, damage, id);
      }
    }

    if (other is WithSensor) {
      return;
    }

    _destroyObject();
    super.onCollision(intersectionPoints, other);
  }

  void _destroyObject() {
    removeAll(children);
    removeFromParent();
    if (animationDestroy != null) {
      _destroyByAngle();
    }
    onDestroy?.call();
  }

  void _verifyExistInWorld(double dt) {
    if (_intervalTick.update(dt) && !isRemoving) {
      final canSee = gameRef.camera.canSee(this);
      if (!canSee) {
        removeFromParent();
      }
    }
  }

  void _destroyByAngle() {
    final nextX = (width / 2) * _cosAngle;
    final nextY = (height / 2) * _senAngle;

    final innerSize = destroySize ?? size;
    final rect = rectCollision;
    final diffBase = Offset(
          rect.center.dx + nextX,
          rect.center.dy + nextY,
        ) -
        rect.center;

    final positionDestroy = center.translated(diffBase.dx, diffBase.dy);

    if (hasGameRef) {
      gameRef.add(
        AnimatedGameObject(
          animation: animationDestroy,
          position: Rect.fromCenter(
            center: positionDestroy.toOffset(),
            width: innerSize.x,
            height: innerSize.y,
          ).positionVector2,
          lightingConfig: lighting.config,
          size: innerSize,
          loop: false,
          renderAboveComponents: true,
        ),
      );
      _applyDestroyDamage(
        Rect.fromLTWH(
          positionDestroy.x,
          positionDestroy.y,
          innerSize.x,
          innerSize.y,
        ),
      );
    }
  }

  void _applyDestroyDamage(Rect rectPosition) {
    gameRef.add(
      DamageHitbox(
        id: id,
        position: rectPosition.positionVector2,
        damage: damage,
        origin: attackFrom,
        size: rectPosition.size.toVector2(),
      ),
    );
  }

  @override
  void onMount() {
    super.onMount();
    anchor = Anchor.center;
  }

  @override
  Future<void> onLoad() {
    add(shapeCollision ?? RectangleHitbox(size: size, isSolid: true));
    return super.onLoad();
  }
}
