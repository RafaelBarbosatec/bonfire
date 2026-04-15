import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:flutter/widgets.dart';

/// Animated component used like range attack.
class FlyingAttackGameObject extends AnimatedGameObject
    with Movement, CanNotSeen, BlockMovementCollision {
  final dynamic id;
  Future<SpriteAnimation>? animationDestroy;
  final Direction? direction;
  final double damage;
  final AttackOriginEnum attackFrom;
  final bool withDecorationCollision;
  final VoidCallback? onDestroy;
  final bool enabledDiagonal;
  final Vector2? destroySize;
  double _cosAngle = 0;
  double _senAngle = 0;
  ShapeHitbox? collision;

  FlyingAttackGameObject({
    required super.position,
    required super.size,
    required super.animation,
    super.angle = 0,
    this.direction,
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
    this.collision,
  }) {
    this.speed = speed;

    _cosAngle = cos(angle);
    _senAngle = sin(angle);

    if (direction != null) {
      moveFromDirection(direction!, enabledDiagonal: enabledDiagonal);
    } else {
      moveFromAngle(angle);
    }
  }

  FlyingAttackGameObject.byDirection({
    required super.position,
    required super.size,
    required super.animation,
    required this.direction,
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
    this.collision,
  }) {
    this.speed = speed;
    moveFromDirection(direction!, enabledDiagonal: enabledDiagonal);
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
    this.collision,
  }) : direction = null {
    this.speed = speed;

    _cosAngle = cos(angle);
    _senAngle = sin(angle);

    moveFromAngle(angle);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _verifyExistInWorld(dt);
  }

  @override
  bool onComponentTypeCheck(PositionComponent other) {
    if (other is Sensor) {
      return false;
    }

    if (!withDecorationCollision && other is GameDecoration) {
      return false;
    }

    return super.onComponentTypeCheck(other);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Attackable) {
      if (!other.checkCanReceiveDamage(attackFrom)) {
        return;
      }

      if (animationDestroy == null) {
        other.handleAttack(attackFrom, damage, id);
      }
    }

    if (other is Sensor) {
      return;
    }

    _destroyObject();
    super.onCollision(intersectionPoints, other);
  }

  void _destroyObject() {
    if (isRemoving || isRemoved) {
      return;
    }
    removeAll(children);
    removeFromParent();
    if (animationDestroy != null) {
      final currentDirection = direction;
      if (currentDirection != null) {
        _destroyByDirection(currentDirection);
      } else {
        _destroyByAngle();
      }
    }
    onDestroy?.call();
  }

  void _verifyExistInWorld(double dt) {
    if (checkInterval('checkCanSee', 1000, dt) && !isRemoving) {
      final canSee = gameRef.camera.canSee(this);
      if (!canSee) {
        removeFromParent();
      }
    }
  }

  void _destroyByDirection(Direction direction) {
    Vector2 positionDestroy;

    final double biggerSide = max(width, height);
    var addCenterX = 0.0;
    var addCenterY = 0.0;

    const divisionFactor = 2.0;

    if (destroySize != null) {
      addCenterX = (size.x - destroySize!.x) / divisionFactor;
      addCenterY = (size.y - destroySize!.y) / divisionFactor;
    }
    switch (direction) {
      case Direction.left:
        positionDestroy = Vector2(
          left - (biggerSide / divisionFactor) + addCenterX,
          top + addCenterY,
        );
        break;
      case Direction.right:
        positionDestroy = Vector2(
          left + (biggerSide / divisionFactor) + addCenterX,
          top + addCenterY,
        );
        break;
      case Direction.up:
        positionDestroy = Vector2(
          left + addCenterX,
          top - (biggerSide / divisionFactor) + addCenterY,
        );
        break;
      case Direction.down:
        positionDestroy = Vector2(
          left + addCenterX,
          top + (biggerSide / divisionFactor) + addCenterY,
        );
        break;
      case Direction.upLeft:
        positionDestroy = Vector2(
          left - (biggerSide / divisionFactor) + addCenterX,
          top - (biggerSide / divisionFactor) + addCenterY,
        );
        break;
      case Direction.upRight:
        positionDestroy = Vector2(
          left + (biggerSide / divisionFactor) + addCenterX,
          top - (biggerSide / divisionFactor) + addCenterY,
        );
        break;
      case Direction.downLeft:
        positionDestroy = Vector2(
          left - (biggerSide / divisionFactor) + addCenterX,
          top + (biggerSide / divisionFactor) + addCenterY,
        );
        break;
      case Direction.downRight:
        positionDestroy = Vector2(
          left + (biggerSide / divisionFactor) + addCenterX,
          top + (biggerSide / divisionFactor) + addCenterY,
        );
        break;
    }

    if (hasGameRef) {
      final innerSize = destroySize ?? size;
      gameRef.add(
        AnimatedGameObject(
          animation: animationDestroy,
          position: positionDestroy,
          size: innerSize,
          lightingConfig: lightingConfig,
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
          lightingConfig: lightingConfig,
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
  bool onBlockMovement(Set<Vector2> intersectionPoints, GameComponent other) {
    return false;
  }

  @override
  void onMount() {
    anchor = Anchor.center;
    super.onMount();
  }

  @override
  Future<void> onLoad() {
    add(collision ?? RectangleHitbox(size: size, isSolid: true));
    return super.onLoad();
  }
}
