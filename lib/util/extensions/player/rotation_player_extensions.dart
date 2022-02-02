import 'package:bonfire/collision/collision_config.dart';
import 'package:bonfire/lighting/lighting_config.dart';
import 'package:bonfire/player/rotation_player.dart';
import 'package:bonfire/util/extensions/game_component_extensions.dart';
import 'package:flame/components.dart';
import 'package:flutter/widgets.dart';

extension RotationPlayerExtensions on RotationPlayer {
  void simpleAttackRange({
    /// use animation facing right.
    required Future<SpriteAnimation> animation,
    required Vector2 size,
    Future<SpriteAnimation>? animationDestroy,
    dynamic id,
    double speed = 150,
    double damage = 1,
    double? radAngleDirection,
    bool withCollision = true,
    VoidCallback? onDestroy,
    CollisionConfig? collision,
    LightingConfig? lightingConfig,
  }) {
    double? angle = radAngleDirection ?? this.angle;

    this.simpleAttackRangeByAngle(
      radAngleDirection: angle,
      animation: animation,
      animationDestroy: animationDestroy,
      size: size,
      id: id,
      speed: speed,
      damage: damage,
      withCollision: withCollision,
      onDestroy: onDestroy,
      collision: collision,
      lightingConfig: lightingConfig,
    );
  }

  void simpleAttackMelee({
    required Future<SpriteAnimation> animationTop,
    required double damage,
    required Vector2 size,
    dynamic id,
    double? radAngleDirection,
    bool withPush = true,
  }) {
    double? angle = radAngleDirection ?? this.angle;
    this.simpleAttackMeleeByAngle(
      radAngleDirection: angle,
      animationTop: animationTop,
      damage: damage,
      id: id,
      size: size,
      withPush: withPush,
    );
  }
}
