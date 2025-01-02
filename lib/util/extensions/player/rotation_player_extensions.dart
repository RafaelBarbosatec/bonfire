import 'package:bonfire/lighting/lighting_config.dart';
import 'package:bonfire/mixins/attackable.dart';
import 'package:bonfire/player/rotation_player.dart';
import 'package:bonfire/util/extensions/game_component_extensions.dart';
import 'package:flame/collisions.dart';
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
    ShapeHitbox? collision,
    LightingConfig? lightingConfig,
    Vector2? centerOffset,
    double marginFromOrigin = 16,
  }) {
    final angle = radAngleDirection ?? this.angle;

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
      attackFrom: AttackOriginEnum.PLAYER_OR_ALLY,
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
    double marginFromCenter = 16,
    Vector2? centerOffset,
  }) {
    final angle = radAngleDirection ?? this.angle;
    simpleAttackMeleeByAngle(
      angle: angle,
      animation: animation,
      damage: damage,
      id: id,
      size: size,
      withPush: withPush,
      marginFromCenter: marginFromCenter,
      centerOffset: centerOffset,
      attackFrom: AttackOriginEnum.PLAYER_OR_ALLY,
    );
  }
}
