import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/assets_loader.dart';
import 'package:flutter/widgets.dart';

class FlyingAttackObject extends GameComponent
    with WithSpriteAnimation, WithAssetsLoader, ObjectCollision, Lighting {
  final dynamic id;
  SpriteAnimation? flyAnimation;
  Future<SpriteAnimation>? animationDestroy;
  final Direction? direction;
  final double speed;
  final double damage;
  final AttackFromEnum attackFrom;
  final bool withDecorationCollision;
  final VoidCallback? onDestroy;
  final bool enableDiagonal;
  final Vector2? destroySize;
  double _cosAngle = 0;
  double _senAngle = 0;

  final IntervalTick _timerVerifyCollision = IntervalTick(50);

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
    this.enableDiagonal = true,
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
    this.enableDiagonal = true,
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
    this.enableDiagonal = true,
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
      _meveByDirection(direction!, dt);
    } else {
      _moveByAngle(dt);
    }

    if (!_verifyExistInWorld()) {
      removeFromParent();
    } else {
      _verifyCollision(dt);
    }
  }

  void _verifyCollision(double dt) {
    if (shouldRemove) return;
    if (!_timerVerifyCollision.update(dt)) return;

    bool destroy = false;

    gameRef.visibleAttackables().where((a) {
      final fromCorrect = (attackFrom == AttackFromEnum.ENEMY
          ? a.receivesAttackFromEnemy()
          : a.receivesAttackFromPlayer());

      final overlap = a.rectAttackable().overlaps(rectCollision);

      return fromCorrect && overlap;
    }).forEach((enemy) {
      enemy.receiveDamage(damage, id);
      destroy = true;
    });

    if (withDecorationCollision && !destroy) {
      destroy = isCollision().isNotEmpty;
    }

    if (destroy) {
      if (animationDestroy != null) {
        if (direction != null) {
          _destroyByDiretion(direction!, dt);
        } else {
          _destroyByAngle();
        }
      }
      setupCollision(CollisionConfig(collisions: []));
      removeFromParent();
      this.onDestroy?.call();
    }
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

  void _meveByDirection(Direction direction, double dt) {
    switch (direction) {
      case Direction.left:
        position = position.translate((speed * dt) * -1, 0);
        break;
      case Direction.right:
        position = position.translate((speed * dt), 0);
        break;
      case Direction.up:
        position = position.translate(0, (speed * dt) * -1);
        break;
      case Direction.down:
        position = position.translate(0, (speed * dt));
        break;
      case Direction.upLeft:
        if (enableDiagonal) {
          position = position.translate((speed * dt) * -1, (speed * dt) * -1);
        } else {
          position = position.translate((speed * dt) * -1, 0);
        }
        break;
      case Direction.upRight:
        if (enableDiagonal) {
          position = position.translate((speed * dt), (speed * dt) * -1);
        } else {
          position = position.translate((speed * dt), 0);
        }

        break;
      case Direction.downLeft:
        if (enableDiagonal) {
          position = position.translate((speed * dt) * -1, (speed * dt));
        } else {
          position = position.translate((speed * dt) * -1, 0);
        }

        break;
      case Direction.downRight:
        if (enableDiagonal) {
          position = position.translate((speed * dt), (speed * dt));
        } else {
          position = position.translate((speed * dt), 0);
        }
        break;
    }
  }

  void _moveByAngle(double dt) {
    double nextX = (speed * dt) * _cosAngle;
    double nextY = (speed * dt) * _senAngle;
    Offset nextPoint = Offset(nextX, nextY);

    Offset diffBase = Offset(center.x + nextPoint.dx, center.y + nextPoint.dy) -
        center.toOffset();

    position.add(diffBase.toVector2());
  }

  void _destroyByDiretion(Direction direction, double dt) {
    Vector2 positionDestroy;

    double biggerSide = max(width, height);
    double addCenterX = 0;
    double addCenterY = 0;

    if (destroySize != null) {
      addCenterX = ((size.x - destroySize!.x) / 2);
      addCenterY = ((size.y - destroySize!.y) / 2);
    }
    switch (direction) {
      case Direction.left:
        positionDestroy = Vector2(
          left - (biggerSide / 4) + addCenterX,
          top + addCenterY,
        );
        break;
      case Direction.right:
        positionDestroy = Vector2(
          left + (biggerSide / 4) + addCenterX,
          top + addCenterY,
        );
        break;
      case Direction.up:
        positionDestroy = Vector2(
          left + addCenterX,
          top - (biggerSide / 4) + addCenterY,
        );
        break;
      case Direction.down:
        positionDestroy = Vector2(
          left + addCenterX,
          top + (biggerSide / 4) + addCenterY,
        );
        break;
      case Direction.upLeft:
        positionDestroy = Vector2(
          left - (biggerSide / 4) + addCenterX,
          top - (biggerSide / 4) + addCenterY,
        );
        break;
      case Direction.upRight:
        positionDestroy = Vector2(
          left + (biggerSide / 4) + addCenterX,
          top - (biggerSide / 4) + addCenterY,
        );
        break;
      case Direction.downLeft:
        positionDestroy = Vector2(
          left - (biggerSide / 4) + addCenterX,
          top + (biggerSide / 4) + addCenterY,
        );
        break;
      case Direction.downRight:
        positionDestroy = Vector2(
          left + (biggerSide / 4) + addCenterX,
          top + (biggerSide / 4) + addCenterY,
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
    double nextX = (width / 4) * _cosAngle;
    double nextY = (height / 4) * _senAngle;

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
