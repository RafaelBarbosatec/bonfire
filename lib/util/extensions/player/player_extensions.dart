import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/geometry/polygon.dart';
import 'package:flutter/widgets.dart';

extension PlayerExtensions on Player {
  /// This method we notify when detect the enemy when enter in [radiusVision] configuration
  /// Method that bo used in [update] method.
  /// [visionAngle] in radians
  /// [angle] in radians. is automatically picked up using the component's direction.
  PolygonShape? seeEnemy({
    required Function(List<Enemy>) observed,
    VoidCallback? notObserved,
    double radiusVision = 32,
    double? visionAngle,
    double? angle,
  }) {
    if (isDead) return null;
    return seeComponentType<Enemy>(
      observed: observed,
      notObserved: notObserved,
      radiusVision: radiusVision,
      angle: angle ?? lastDirection.toRadians(),
      visionAngle: visionAngle,
    );
  }

  void simpleAttackMelee({
    Future<SpriteAnimation>? animationRight,
    required double damage,
    required Vector2 size,
    dynamic id,
    Direction? direction,
    bool withPush = true,
    double? sizePush,
    Vector2? centerOffset,
    double? marginFromCenter,
    bool diagonalEnabled = true,
  }) {
    simpleAttackMeleeByDirection(
      direction: direction ?? _getLastDirection(diagonalEnabled),
      animationRight: animationRight,
      damage: damage,
      id: id,
      size: size,
      withPush: withPush,
      sizePush: sizePush,
      attackFrom: AttackFromEnum.PLAYER_OR_ALLY,
      centerOffset: centerOffset,
      marginFromCenter: marginFromCenter,
    );
  }

  void simpleAttackRange({
    required Future<SpriteAnimation> animationRight,
    Future<SpriteAnimation>? animationDestroy,
    required Vector2 size,
    Vector2? destroySize,
    dynamic id,
    double speed = 150,
    double damage = 1,
    Direction? direction,
    bool withCollision = true,
    bool diagonalEnabled = true,
    VoidCallback? onDestroy,
    ShapeHitbox? collision,
    LightingConfig? lightingConfig,
  }) {
    Direction attackDirection = direction ?? _getLastDirection(diagonalEnabled);
    simpleAttackRangeByDirection(
      direction: attackDirection,
      animationRight: animationRight,
      animationDestroy: animationDestroy,
      size: size,
      id: id,
      speed: speed,
      damage: damage,
      withCollision: withCollision,
      onDestroy: onDestroy,
      destroySize: destroySize,
      collision: collision,
      lightingConfig: lightingConfig,
      attackFrom: AttackFromEnum.PLAYER_OR_ALLY,
    );
  }

  Direction _getLastDirection(bool diagonalEnabled) {
    if (diagonalEnabled) {
      return lastDirection;
    }

    switch (lastDirection) {
      case Direction.left:
      case Direction.right:
      case Direction.up:
      case Direction.down:
        return lastDirection;
      case Direction.upLeft:
      case Direction.upRight:
      case Direction.downLeft:
      case Direction.downRight:
        return lastDirectionHorizontal;
    }
  }
}
