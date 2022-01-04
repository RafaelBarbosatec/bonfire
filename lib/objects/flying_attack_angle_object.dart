import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/assets_loader.dart';
import 'package:flutter/widgets.dart';

class FlyingAttackAngleObject extends AnimatedObject
    with ObjectCollision, Lighting {
  final dynamic id;
  SpriteAnimation? flyAnimation;
  Future<SpriteAnimation>? destroyAnimation;
  final double speed;
  final double damage;
  final AttackFromEnum attackFrom;
  final bool withCollision;
  final VoidCallback? onDestroy;
  AssetsLoader? _loader = AssetsLoader();

  late double _cosAngle;
  late double _senAngle;

  final IntervalTick _timerVerifyCollision = IntervalTick(40);

  FlyingAttackAngleObject({
    required Vector2 position,
    required Vector2 size,
    required Future<SpriteAnimation> flyAnimation,
    double radAngle = 0,
    this.id,
    this.destroyAnimation,
    this.speed = 150,
    this.damage = 1,
    this.attackFrom = AttackFromEnum.ENEMY,
    this.withCollision = true,
    this.onDestroy,
    LightingConfig? lightingConfig,
    CollisionConfig? collision,
  }) {
    _loader?.add(AssetToLoad(flyAnimation, (value) {
      return this.flyAnimation = value;
    }));

    this.angle = radAngle;
    this.size = size;
    this.position = position;

    if (lightingConfig != null) setupLighting(lightingConfig);

    setupCollision(
      collision ??
          CollisionConfig(
            collisions: [
              CollisionArea.rectangle(size: Vector2(width, height)),
            ],
          ),
    );

    _cosAngle = cos(radAngle);
    _senAngle = sin(radAngle);
    angle = radAngle + (pi / 2);
  }

  @override
  void update(double dt) {
    super.update(dt);

    double nextX = (speed * dt) * _cosAngle;
    double nextY = (speed * dt) * _senAngle;
    Offset nextPoint = Offset(nextX, nextY);

    Offset diffBase = Offset(center.x + nextPoint.dx, center.y + nextPoint.dy) -
        center.toOffset();

    position.add(diffBase.toVector2());

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
      return (attackFrom == AttackFromEnum.ENEMY
              ? a.receivesAttackFromEnemy()
              : a.receivesAttackFromPlayer()) &&
          overlaps(a.rectAttackable());
    }).forEach((enemy) {
      enemy.receiveDamage(damage, id);
      destroy = true;
    });

    if (withCollision && !destroy) {
      destroy = isCollision().isNotEmpty;
    }

    if (destroy) {
      if (destroyAnimation != null) {
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
            animation: destroyAnimation!,
            position: positionDestroy,
            lightingConfig: lightingConfig,
            size: size,
          ),
        );
      }
      setupCollision(CollisionConfig(collisions: []));
      removeFromParent();
      this.onDestroy?.call();
    }
  }

  bool _verifyExistInWorld() {
    Size? mapSize = gameRef.map.mapSize;

    if (mapSize == null) return true;
    if (left < 0) {
      return false;
    }
    if (right > mapSize.width) {
      return false;
    }
    if (top < 0) {
      return false;
    }
    if (bottom > mapSize.height) {
      return false;
    }

    return true;
  }

  @override
  Future<void> onLoad() async {
    await _loader?.load();
    _loader = null;
    animation = this.flyAnimation;
    return super.onLoad();
  }
}
