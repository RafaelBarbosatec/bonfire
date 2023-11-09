import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:flutter/widgets.dart';

/// Animated component used like range attack.
class FlyingAttackGameObject extends AnimatedGameObject
    with Movement, BlockMovementCollision {
  final dynamic id;
  Future<SpriteAnimation>? animationDestroy;
  final Direction? direction;
  final double damage;
  final AttackFromEnum attackFrom;
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
    this.attackFrom = AttackFromEnum.ENEMY,
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
    movementOnlyVisible = false;
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
    this.attackFrom = AttackFromEnum.ENEMY,
    this.withDecorationCollision = true,
    this.onDestroy,
    this.enabledDiagonal = true,
    super.lightingConfig,
    this.collision,
  }) {
    this.speed = speed;
    moveFromDirection(direction!, enabledDiagonal: enabledDiagonal);
    movementOnlyVisible = false;
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
    this.attackFrom = AttackFromEnum.ENEMY,
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
    movementOnlyVisible = false;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!_verifyExistInWorld()) {
      removeFromParent();
    }
  }

  @override
  bool onComponentTypeCheck(PositionComponent other) {
    if (other is Sensor) {
      return false;
    }
    if (other is Attackable) {
      if (!other.checkCanReceiveDamage(attackFrom)) {
        return false;
      }
    }
    return super.onComponentTypeCheck(other);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Attackable && !other.isRemoving) {
      other.receiveDamage(attackFrom, damage, id);
    }
    if (other is GameComponent) {
      _destroyObject(other);
    }
    super.onCollision(intersectionPoints, other);
  }

  void _destroyObject(GameComponent component) {
    if (isRemoving) return;
    removeFromParent();
    if (animationDestroy != null) {
      if (direction != null) {
        _destroyByDirection(direction!, dtUpdate, component);
      } else {
        _destroyByAngle(component);
      }
    }
    removeAll(children);
    onDestroy?.call();
  }

  bool _verifyExistInWorld() {
    return gameRef.map.toRect().contains(center.toOffset());
  }

  void _destroyByDirection(
    Direction direction,
    double dt,
    GameComponent component,
  ) {
    Vector2 positionDestroy;

    double biggerSide = max(width, height);
    double addCenterX = 0;
    double addCenterY = 0;

    const double divisionFactor = 2;

    if (destroySize != null) {
      addCenterX = ((size.x - destroySize!.x) / divisionFactor);
      addCenterY = ((size.y - destroySize!.y) / divisionFactor);
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
      Vector2 innerSize = destroySize ?? size;
      gameRef.add(
        AnimatedGameObject(
          animation: animationDestroy!,
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
        component,
      );
    }
  }

  void _destroyByAngle(GameComponent component) {
    double nextX = (width / 2) * _cosAngle;
    double nextY = (height / 2) * _senAngle;

    Vector2 innerSize = destroySize ?? size;
    final rect = rectCollision;
    Offset diffBase = Offset(
          rect.center.dx + nextX,
          rect.center.dy + nextY,
        ) -
        rect.center;

    final positionDestroy = center.translated(diffBase.dx, diffBase.dy);

    if (hasGameRef) {
      gameRef.add(
        AnimatedGameObject(
          animation: animationDestroy!,
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
        component,
      );
    }
  }

  void _applyDestroyDamage(Rect rectPosition, GameComponent component) {
    gameRef.attackables(onlyVisible: true).forEach((element) {
      if (element.rectAttackable().overlaps(rectPosition) &&
          element != component) {
        element.receiveDamage(attackFrom, damage, id);
      }
    });
  }

  @override
  void onMount() {
    anchor = Anchor.center;
    super.onMount();
  }

  @override
  Future<void> onLoad() {
    if (collision != null) {
      add(collision!);
    } else {
      add(RectangleHitbox(size: size, isSolid: true));
    }

    return super.onLoad();
  }
}
