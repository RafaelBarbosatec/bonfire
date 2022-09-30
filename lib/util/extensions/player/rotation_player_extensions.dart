import 'package:bonfire/collision/collision_config.dart';
import 'package:bonfire/lighting/lighting_config.dart';
import 'package:bonfire/mixins/attackable.dart';
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
    Vector2? destroySize,
    dynamic id,
    double speed = 150,
    double damage = 1,
    double? radAngleDirection,
    bool withDecorationCollision = true,
    VoidCallback? onDestroy,
    CollisionConfig? collision,
    LightingConfig? lightingConfig,
    Vector2? centerOffset,
    double marginFromOrigin = 16,
  }) {
    double? angle = radAngleDirection ?? this.angle;

    simpleAttackRangeByAngle(
      angle: angle,
      animation: animation,
      animationDestroy: animationDestroy,
      size: size,
      id: id,
      speed: speed,
      damage: damage,
      withDecorationCollision: withDecorationCollision,
      onDestroy: onDestroy,
      destroySize: destroySize,
      collision: collision,
      lightingConfig: lightingConfig,
      centerOffset: centerOffset,
      marginFromOrigin: marginFromOrigin,
      attackFrom: AttackFromEnum.PLAYER_OR_ALLY,
    );
  }

  void simpleAttackMelee({
    /// use animation facing right.
    required Future<SpriteAnimation> animation,
    required double damage,
    required Vector2 size,
    dynamic id,
    double? radAngleDirection,
    bool withPush = true,
    double marginFromOrigin = 16,
    Vector2? centerOffset,
  }) {
    double? angle = radAngleDirection ?? this.angle;
    simpleAttackMeleeByAngle(
      angle: angle,
      animation: animation,
      damage: damage,
      id: id,
      size: size,
      withPush: withPush,
      marginFromOrigin: marginFromOrigin,
      centerOffset: centerOffset,
      attackFrom: AttackFromEnum.PLAYER_OR_ALLY,
    );
  }
}
