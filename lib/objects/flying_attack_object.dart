import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:flutter/widgets.dart';

class FlyingAttackObject extends GameComponent
    with
        UseSpriteAnimation,
        UseAssetsLoader,
        ObjectCollision,
        Lighting,
        Movement {
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

  FlyingAttackObject({
    required Vector2 position,
    required Vector2 size,
    required Future<SpriteAnimation> flyAnimation,
    this.direction,
    double angle = 0,
    this.id,
    this.animationDestroy,
    this.destroySize,
    double speed = 150,
    this.damage = 1,
    this.attackFrom = AttackFromEnum.ENEMY,
    this.withDecorationCollision = true,
    this.onDestroy,
    this.enabledDiagonal = true,
    LightingConfig? lightingConfig,
    CollisionConfig? collision,
  }) {
    this.speed = speed;
    loader?.add(AssetToLoad(flyAnimation, (value) {
      animation = value;
    }));

    this.position = position;
    this.size = size;
    this.angle = angle;
    _cosAngle = cos(angle);
    _senAngle = sin(angle);

    if (lightingConfig != null) setupLighting(lightingConfig);

    setupCollision(
      collision ??
          CollisionConfig(
            collisions: [
              CollisionArea.rectangle(
                size: Vector2(width, height),
              ),
            ],
          ),
    );
  }

  FlyingAttackObject.byDirection({
    required Vector2 position,
    required Vector2 size,
    required Future<SpriteAnimation> flyAnimation,
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
    LightingConfig? lightingConfig,
    CollisionConfig? collision,
  }) {
    this.speed = speed;
    loader?.add(AssetToLoad(flyAnimation, (value) {
      return animation = value;
    }));

    this.position = position;
    this.size = size;

    if (lightingConfig != null) setupLighting(lightingConfig);

    setupCollision(
      collision ??
          CollisionConfig(
            collisions: [
              CollisionArea.rectangle(
                size: Vector2(width, height),
              ),
            ],
          ),
    );
  }

  FlyingAttackObject.byAngle({
    required Vector2 position,
    required Vector2 size,
    required Future<SpriteAnimation> flyAnimation,
    required double angle,
    this.id,
    this.animationDestroy,
    this.destroySize,
    double speed = 150,
    this.damage = 1,
    this.attackFrom = AttackFromEnum.ENEMY,
    this.withDecorationCollision = true,
    this.onDestroy,
    this.enabledDiagonal = true,
    LightingConfig? lightingConfig,
    CollisionConfig? collision,
  }) : direction = null {
    this.speed = speed;
    loader?.add(AssetToLoad(flyAnimation, (value) {
      return animation = value;
    }));

    this.position = position;
    this.size = size;
    this.angle = angle;
    _cosAngle = cos(angle);
    _senAngle = sin(angle);

    if (lightingConfig != null) setupLighting(lightingConfig);

    setupCollision(
      collision ??
          CollisionConfig(
            collisions: [
              CollisionArea.rectangle(
                size: Vector2(width, height),
              ),
            ],
          ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (direction != null) {
      moveFromDirection(direction!, enabledDiagonal: enabledDiagonal);
    } else {
      moveFromAngle(speed, angle);
    }

    if (!_verifyExistInWorld()) {
      removeFromParent();
    }
  }

  @override
  bool onCollision(GameComponent component, bool active) {
    if (component is Attackable && !component.isRemoving) {
      component.receiveDamage(attackFrom, damage, id);
    } else if (!withDecorationCollision) {
      return false;
    }
    _destroyObject(component);
    return true;
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
    setupCollision(CollisionConfig(collisions: []));
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
        AnimatedObjectOnce(
          animation: animationDestroy!,
          position: positionDestroy,
          size: innerSize,
          lightingConfig: lightingConfig,
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

    Offset diffBase = Offset(
          rectCollision.center.dx + nextX,
          rectCollision.center.dy + nextY,
        ) -
        rectCollision.center;

    final positionDestroy = center.translate(diffBase.dx, diffBase.dy);

    if (hasGameRef) {
      gameRef.add(
        AnimatedObjectOnce(
          animation: animationDestroy!,
          position: Rect.fromCenter(
            center: positionDestroy.toOffset(),
            width: innerSize.x,
            height: innerSize.y,
          ).positionVector2,
          lightingConfig: lightingConfig,
          size: innerSize,
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
    gameRef.visibleAttackables().forEach((element) {
      if (element.rectAttackable().overlaps(rectPosition) &&
          element != component) {
        element.receiveDamage(attackFrom, damage, id);
      }
    });
  }
}
