import 'dart:math';

import 'package:bonfire/collision/collision_area.dart';
import 'package:bonfire/collision/collision_config.dart';
import 'package:bonfire/collision/object_collision.dart';
import 'package:bonfire/lighting/lighting.dart';
import 'package:bonfire/lighting/lighting_config.dart';
import 'package:bonfire/objects/animated_object.dart';
import 'package:bonfire/objects/animated_object_once.dart';
import 'package:bonfire/util/assets_loader.dart';
import 'package:bonfire/util/interval_tick.dart';
import 'package:bonfire/util/vector2rect.dart';
import 'package:flame/extensions.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/widgets.dart';

class FlyingAttackAngleObject extends AnimatedObject
    with ObjectCollision, Lighting {
  final dynamic id;
  SpriteAnimation? flyAnimation;
  Future<SpriteAnimation>? destroyAnimation;
  final double radAngle;
  final double speed;
  final double damage;
  final double width;
  final double height;
  final bool damageInPlayer;
  final bool withCollision;
  final VoidCallback? destroyedObject;
  final _loader = AssetsLoader();

  late double _cosAngle;
  late double _senAngle;
  late double _rotate;

  final IntervalTick _timerVerifyCollision = IntervalTick(40);

  FlyingAttackAngleObject({
    required Vector2 position,
    required Future<SpriteAnimation> flyAnimation,
    required this.radAngle,
    required this.width,
    required this.height,
    this.id,
    this.destroyAnimation,
    this.speed = 150,
    this.damage = 1,
    this.damageInPlayer = true,
    this.withCollision = true,
    this.destroyedObject,
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
            collisions: [CollisionArea.rectangle(size: Size(width, height))],
          ),
    );

    _cosAngle = cos(radAngle);
    _senAngle = sin(radAngle);
    _rotate = radAngle == 0.0 ? 0.0 : radAngle + (pi / 2);
  }

  @override
  void update(double dt) {
    super.update(dt);

    double nextX = (speed * dt) * _cosAngle;
    double nextY = (speed * dt) * _senAngle;
    Offset nextPoint = Offset(nextX, nextY);

    Offset diffBase = Offset(position.center.dx + nextPoint.dx,
            position.center.dy + nextPoint.dy) -
        position.center;

    position = Vector2Rect.fromRect(position.rect.shift(diffBase));

    if (!_verifyExistInWorld()) {
      remove();
    } else {
      _verifyCollision(dt);
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.save();
    canvas.translate(position.rect.center.dx, position.rect.center.dy);
    canvas.rotate(_rotate);
    canvas.translate(-position.rect.center.dx, -position.rect.center.dy);
    super.render(canvas);
    canvas.restore();
  }

  void _verifyCollision(double dt) {
    if (shouldRemove) return;
    if (!_timerVerifyCollision.update(dt)) return;

    bool destroy = false;

    gameRef.visibleAttackables().where((a) {
      return (damageInPlayer
              ? a.receivesAttackFromEnemy()
              : a.receivesAttackFromPlayer()) &&
          a.rectAttackable().rect.overlaps(position.rect);
    }).forEach((enemy) {
      enemy.receiveDamage(damage, id);
      destroy = true;
    });

    if (withCollision && !destroy) {
      destroy = isCollision(
        shouldTriggerSensors: false,
      );
    }

    if (destroy) {
      if (destroyAnimation != null) {
        double nextX = (width / 4) * _cosAngle;
        double nextY = (height / 4) * _senAngle;
        Offset nextPoint = Offset(nextX, nextY);

        Offset diffBase = Offset(rectCollision.rect.center.dx + nextPoint.dx,
                rectCollision.rect.center.dy + nextPoint.dy) -
            rectCollision.rect.center;

        final positionDestroy = Vector2Rect.fromRect(
          position.rect.shift(diffBase),
        );

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
      this.destroyedObject?.call();
    }
  }

  bool _verifyExistInWorld() {
    Size? mapSize = gameRef.map.mapSize;
    if (mapSize == null) return true;
    if (position.rect.left < 0) {
      return false;
    }
    if (position.rect.right > mapSize.width) {
      return false;
    }
    if (position.rect.top < 0) {
      return false;
    }
    if (position.rect.bottom > mapSize.height) {
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
