import 'package:bonfire/collision/collision_config.dart';
import 'package:bonfire/lighting/lighting_config.dart';
import 'package:bonfire/player/extensions.dart';
import 'package:bonfire/player/rotation/rotation_player.dart';
import 'package:flame/components.dart';
import 'package:flutter/widgets.dart';

extension RotationPlayerExtensions on RotationPlayer {
  void simpleAttackRange({
    required Future<SpriteAnimation> animationTop,
    required double width,
    required double height,
    Future<SpriteAnimation>? animationDestroy,
    dynamic id,
    double speed = 150,
    double damage = 1,
    double? radAngleDirection,
    bool withCollision = true,
    VoidCallback? destroy,
    CollisionConfig? collision,
    LightingConfig? lightingConfig,
  }) {
    if (this.currentRadAngle == 0) return;

    double? angle = radAngleDirection ?? this.currentRadAngle;

    if (angle != null) {
      this.simpleAttackRangeByAngle(
        radAngleDirection: angle,
        animationTop: animationTop,
        animationDestroy: animationDestroy,
        width: width,
        height: height,
        id: id,
        speed: speed,
        damage: damage,
        withCollision: withCollision,
        destroy: destroy,
        collision: collision,
        lightingConfig: lightingConfig,
      );
    }
  }

  void simpleAttackMelee({
    required Future<SpriteAnimation> animationTop,
    required double damage,
    required double height,
    required double width,
    dynamic id,
    double? radAngleDirection,
    bool withPush = true,
  }) {
    double? angle = radAngleDirection ?? this.currentRadAngle;
    if (angle != null) {
      this.simpleAttackMeleeByAngle(
        radAngleDirection: angle,
        animationTop: animationTop,
        damage: damage,
        id: id,
        height: height,
        width: width,
        withPush: withPush,
      );
    }
  }
}
