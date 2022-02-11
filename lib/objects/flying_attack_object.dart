import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/assets_loader.dart';
import 'package:flutter/widgets.dart';

class FlyingAttackObject extends GameComponent
    with
        WithSpriteAnimation,
        WithAssetsLoader,
        ObjectCollision,
        Lighting,
        Movement {
  final dynamic id;
  SpriteAnimation? flyAnimation;
  Future<SpriteAnimation>? animationDestroy;
  final Direction? direction;
  final double speed;
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
    this.speed = 150,
    this.damage = 1,
    this.attackFrom = AttackFromEnum.ENEMY,
    this.withDecorationCollision = true,
    this.onDestroy,
    this.enabledDiagonal = true,
    LightingConfig? lightingConfig,
    CollisionConfig? collision,
  }) {
    loader?.add(AssetToLoad(flyAnimation, (value) {
      return this.flyAnimation = value;
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
    this.speed = 150,
    this.damage = 1,
    this.attackFrom = AttackFromEnum.ENEMY,
    this.withDecorationCollision = true,
    this.onDestroy,
    this.enabledDiagonal = true,
    LightingConfig? lightingConfig,
    CollisionConfig? collision,
  }) {
    loader?.add(AssetToLoad(flyAnimation, (value) {
      return this.flyAnimation = value;
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
    this.speed = 150,
    this.damage = 1,
    this.attackFrom = AttackFromEnum.ENEMY,
    this.withDecorationCollision = true,
    this.onDestroy,
    this.enabledDiagonal = true,
    LightingConfig? lightingConfig,
    CollisionConfig? collision,
  }) : direction = null {
    loader?.add(AssetToLoad(flyAnimation, (value) {
      return this.flyAnimation = value;
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
    if (component is Attackable && !component.shouldRemove) {
      if (attackFrom == AttackFromEnum.ENEMY) {
        if (component.receivesAttackFrom == ReceivesAttackFromEnum.ALL ||
            component.receivesAttackFrom == ReceivesAttackFromEnum.ENEMY) {
          component.receiveDamage(damage, id);
        }
      } else if (attackFrom == AttackFromEnum.PLAYER) {
        if (component.receivesAttackFrom == ReceivesAttackFromEnum.ALL ||
            component.receivesAttackFrom == ReceivesAttackFromEnum.PLAYER) {
          component.receiveDamage(damage, id);
        }
      }
    } else if (!withDecorationCollision) {
      return false;
    }
    _destroyObject();
    return true;
  }

  void _destroyObject() {
    if (shouldRemove) return;
    if (animationDestroy != null) {
      if (direction != null) {
        _destroyByDirection(direction!, dtUpdate);
      } else {
        _destroyByAngle();
      }
    }
    setupCollision(CollisionConfig(collisions: []));
    removeFromParent();
    this.onDestroy?.call();
  }

  bool _verifyExistInWorld() {
    Size? mapSize = gameRef.map.mapSize;
    final _rect = toRect();
    if (mapSize == null) return true;

    if (_rect.left < 0) {
      return false;
    }
    if (_rect.right > mapSize.width) {
      return false;
    }
    if (_rect.top < 0) {
      return false;
    }
    if (_rect.bottom > mapSize.height) {
      return false;
    }

    return true;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    animation = this.flyAnimation;
  }

  void _destroyByDirection(Direction direction, double dt) {
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

    gameRef.add(
      AnimatedObjectOnce(
        animation: animationDestroy!,
        position: positionDestroy,
        size: destroySize ?? size,
        lightingConfig: lightingConfig,
      ),
    );
  }

  void _destroyByAngle() {
    double nextX = (width / 2) * _cosAngle;
    double nextY = (height / 2) * _senAngle;

    Offset diffBase = Offset(
          rectCollision.center.dx + nextX,
          rectCollision.center.dy + nextY,
        ) -
        rectCollision.center;

    final positionDestroy = position.translate(diffBase.dx, diffBase.dy);

    gameRef.add(
      AnimatedObjectOnce(
        animation: animationDestroy!,
        position: positionDestroy,
        lightingConfig: lightingConfig,
        size: destroySize ?? size,
      ),
    );
  }
}
