import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:flutter/widgets.dart';

extension PlayerExtensions on Player {
  /// This method we notify when detect the enemy when enter in [radiusVision] configuration
  /// Method that bo used in [update] method.
  void seeEnemy({
    required Function(List<Enemy>) observed,
    VoidCallback? notObserved,
    double radiusVision = 32,
  }) {
    if (isDead) return;
    this.seeComponentType<Enemy>(
      observed: observed,
      notObserved: notObserved,
      radiusVision: radiusVision,
    );
  }

  void simpleAttackMelee({
    Future<SpriteAnimation>? animationRight,
    Future<SpriteAnimation>? animationDown,
    Future<SpriteAnimation>? animationLeft,
    Future<SpriteAnimation>? animationUp,
    required double damage,
    required Vector2 size,
    dynamic id,
    Direction? direction,
    bool withPush = true,
    double? sizePush,
  }) {
    Direction attackDirection = direction ?? this.lastDirection;
    this.simpleAttackMeleeByDirection(
      direction: attackDirection,
      animationRight: animationRight,
      animationDown: animationDown,
      animationLeft: animationLeft,
      animationUp: animationUp,
      damage: damage,
      id: id,
      size: size,
      withPush: withPush,
      sizePush: sizePush,
    );
  }

  void simpleAttackRange({
    required Future<SpriteAnimation> animationRight,
    required Future<SpriteAnimation> animationLeft,
    required Future<SpriteAnimation> animationUp,
    required Future<SpriteAnimation> animationDown,
    Future<SpriteAnimation>? animationDestroy,
    required Vector2 size,
    dynamic id,
    double speed = 150,
    double damage = 1,
    Direction? direction,
    bool withCollision = true,
    bool enableDiagonal = true,
    VoidCallback? destroy,
    CollisionConfig? collision,
    LightingConfig? lightingConfig,
  }) {
    Direction attackDirection = direction ?? this.lastDirection;
    this.simpleAttackRangeByDirection(
      direction: attackDirection,
      animationRight: animationRight,
      animationLeft: animationLeft,
      animationUp: animationUp,
      animationDown: animationDown,
      animationDestroy: animationDestroy,
      size: size,
      id: id,
      speed: speed,
      damage: damage,
      withCollision: withCollision,
      destroy: destroy,
      collision: collision,
      enableDiagonal: enableDiagonal,
      lightingConfig: lightingConfig,
    );
  }
}
