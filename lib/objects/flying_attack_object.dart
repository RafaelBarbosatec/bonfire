import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/assets_loader.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/widgets.dart';

class FlyingAttackObject extends AnimatedObject with ObjectCollision, Lighting {
  final dynamic id;
  SpriteAnimation? flyAnimation;
  Future<SpriteAnimation>? destroyAnimation;
  final Direction direction;
  final double speed;
  final double damage;
  final AttackFromEnum attackFrom;
  final bool withDecorationCollision;
  final VoidCallback? onDestroyedObject;
  AssetsLoader? _loader = AssetsLoader();
  final bool enableDiagonal;

  final IntervalTick _timerVerifyCollision = IntervalTick(50);

  FlyingAttackObject({
    required Vector2 position,
    required Vector2 size,
    required Future<SpriteAnimation> flyAnimation,
    required this.direction,
    this.id,
    this.destroyAnimation,
    this.speed = 150,
    this.damage = 1,
    this.attackFrom = AttackFromEnum.ENEMY,
    this.withDecorationCollision = true,
    this.onDestroyedObject,
    this.enableDiagonal = true,
    LightingConfig? lightingConfig,
    CollisionConfig? collision,
  }) {
    _loader?.add(AssetToLoad(flyAnimation, (value) {
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

  @override
  void update(double dt) {
    super.update(dt);

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
      if (destroyAnimation != null) {
        Rect positionDestroy;
        switch (direction) {
          case Direction.left:
            positionDestroy = Rect.fromLTWH(
              rectCollision.left - (width / 2),
              rectCollision.top - ((height - rectCollision.height) / 2),
              width,
              height,
            );
            break;
          case Direction.right:
            positionDestroy = Rect.fromLTWH(
              rectCollision.right - (width / 2),
              rectCollision.top - ((height - rectCollision.height) / 2),
              width,
              height,
            );
            break;
          case Direction.up:
            positionDestroy = Rect.fromLTWH(
              rectCollision.left - ((width - rectCollision.width) / 2),
              rectCollision.top - (height / 2),
              width,
              height,
            );
            break;
          case Direction.down:
            positionDestroy = Rect.fromLTWH(
              rectCollision.left - ((width - rectCollision.width) / 2),
              rectCollision.bottom + (height / 2),
              width,
              height,
            );
            break;
          case Direction.upLeft:
            positionDestroy = Rect.fromLTWH(
              rectCollision.left - (width / 2),
              rectCollision.top,
              width,
              height,
            );
            break;
          case Direction.upRight:
            positionDestroy = Rect.fromLTWH(
              rectCollision.right - (width / 2),
              rectCollision.top,
              width,
              height,
            );
            break;
          case Direction.downLeft:
            positionDestroy = Rect.fromLTWH(
              rectCollision.left - (width / 2),
              rectCollision.top,
              width,
              height,
            );
            break;
          case Direction.downRight:
            positionDestroy = Rect.fromLTWH(
              rectCollision.right - (width / 2),
              rectCollision.top,
              width,
              height,
            );
            break;
        }

        gameRef.add(
          AnimatedObjectOnce(
            animation: destroyAnimation!,
            position: positionDestroy.positionVector2,
            size: positionDestroy.sizeVector2,
            lightingConfig: lightingConfig,
          ),
        );
      }
      setupCollision(CollisionConfig(collisions: []));
      removeFromParent();
      this.onDestroyedObject?.call();
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
    await _loader?.load();
    _loader = null;
    animation = this.flyAnimation;
    return super.onLoad();
  }
}
