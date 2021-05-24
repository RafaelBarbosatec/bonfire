import 'package:bonfire/bonfire.dart';
import 'package:bonfire/collision/collision_config.dart';
import 'package:bonfire/collision/object_collision.dart';
import 'package:bonfire/lighting/lighting.dart';
import 'package:bonfire/lighting/lighting_config.dart';
import 'package:bonfire/objects/animated_object.dart';
import 'package:bonfire/objects/animated_object_once.dart';
import 'package:bonfire/util/assets_loader.dart';
import 'package:bonfire/util/direction.dart';
import 'package:bonfire/util/vector2rect.dart';
import 'package:flame/extensions.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/widgets.dart';

class FlyingAttackObject extends AnimatedObject with ObjectCollision, Lighting {
  final dynamic id;
  SpriteAnimation? flyAnimation;
  Future<SpriteAnimation>? destroyAnimation;
  final Direction direction;
  final double speed;
  final double damage;
  final double width;
  final double height;
  final AttackFromEnum attackFrom;
  final bool withDecorationCollision;
  final VoidCallback? onDestroyedObject;
  final _loader = AssetsLoader();

  final IntervalTick _timerVerifyCollision = IntervalTick(50);

  FlyingAttackObject({
    required Vector2 position,
    required Future<SpriteAnimation> flyAnimation,
    required this.direction,
    required this.width,
    required this.height,
    this.id,
    this.destroyAnimation,
    this.speed = 150,
    this.damage = 1,
    this.attackFrom = AttackFromEnum.ENEMY,
    this.withDecorationCollision = true,
    this.onDestroyedObject,
    LightingConfig? lightingConfig,
    CollisionConfig? collision,
  }) {
    _loader.add(AssetToLoad(flyAnimation, (value) {
      return this.flyAnimation = value;
    }));

    this.position = Vector2Rect(
      position,
      Vector2(width, height),
    );

    if (lightingConfig != null) setupLighting(lightingConfig);

    setupCollision(
      collision ??
          CollisionConfig(
            collisions: [
              CollisionArea.rectangle(
                size: Size(width, height),
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
        position = position.translate((speed * dt) * -1, 0);
        break;
      case Direction.upRight:
        position = position.translate((speed * dt), 0);
        break;
      case Direction.downLeft:
        position = position.translate((speed * dt) * -1, 0);
        break;
      case Direction.downRight:
        position = position.translate((speed * dt), 0);
        break;
    }

    if (!_verifyExistInWorld()) {
      remove();
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
      destroy = isCollision(
        shouldTriggerSensors: false,
      );
    }

    if (destroy) {
      if (destroyAnimation != null) {
        Vector2Rect positionDestroy;
        switch (direction) {
          case Direction.left:
            positionDestroy = Rect.fromLTWH(
              rectCollision.left - (width / 2),
              rectCollision.top - ((height - rectCollision.height) / 2),
              width,
              height,
            ).toVector2Rect();
            break;
          case Direction.right:
            positionDestroy = Rect.fromLTWH(
              rectCollision.right - (width / 2),
              rectCollision.top - ((height - rectCollision.height) / 2),
              width,
              height,
            ).toVector2Rect();
            break;
          case Direction.up:
            positionDestroy = Rect.fromLTWH(
              rectCollision.left - ((width - rectCollision.width) / 2),
              rectCollision.top - (height / 2),
              width,
              height,
            ).toVector2Rect();
            break;
          case Direction.down:
            positionDestroy = Rect.fromLTWH(
              rectCollision.left - ((width - rectCollision.width) / 2),
              rectCollision.bottom + (height / 2),
              width,
              height,
            ).toVector2Rect();
            break;
          case Direction.upLeft:
            positionDestroy = Rect.fromLTWH(
              rectCollision.left - (width / 2),
              rectCollision.top,
              width,
              height,
            ).toVector2Rect();
            break;
          case Direction.upRight:
            positionDestroy = Rect.fromLTWH(
              rectCollision.right - (width / 2),
              rectCollision.top,
              width,
              height,
            ).toVector2Rect();
            break;
          case Direction.downLeft:
            positionDestroy = Rect.fromLTWH(
              rectCollision.left - (width / 2),
              rectCollision.top,
              width,
              height,
            ).toVector2Rect();
            break;
          case Direction.downRight:
            positionDestroy = Rect.fromLTWH(
              rectCollision.right - (width / 2),
              rectCollision.top,
              width,
              height,
            ).toVector2Rect();
            break;
        }

        gameRef.add(
          AnimatedObjectOnce(
            animation: destroyAnimation!,
            position: positionDestroy,
            lightingConfig: lightingConfig,
          ),
        );
      }
      setupCollision(CollisionConfig(collisions: []));
      remove();
      this.onDestroyedObject?.call();
    }
  }

  bool _verifyExistInWorld() {
    Size? mapSize = gameRef.map.mapSize;
    if (mapSize == null) return true;

    if (position.left < 0) {
      return false;
    }
    if (position.right > mapSize.width) {
      return false;
    }
    if (position.top < 0) {
      return false;
    }
    if (position.bottom > mapSize.height) {
      return false;
    }

    return true;
  }

  @override
  Future<void> onLoad() async {
    await _loader.load();
    animation = this.flyAnimation;
  }
}
