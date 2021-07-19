import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/enemy/enemy.dart';
import 'package:bonfire/player/player.dart';
import 'package:bonfire/util/extensions/game_component_extensions.dart';
import 'package:flutter/material.dart';
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
    Future<SpriteAnimation>? animationBottom,
    Future<SpriteAnimation>? animationLeft,
    Future<SpriteAnimation>? animationTop,
    required double damage,
    dynamic id,
    Direction? direction,
    double height = 32,
    double width = 32,
    bool withPush = true,
    double? sizePush,
  }) {
    Direction attackDirection = direction ?? this.lastDirection;
    this.simpleAttackMeleeByDirection(
      direction: attackDirection,
      animationRight: animationRight,
      animationBottom: animationBottom,
      animationLeft: animationLeft,
      animationTop: animationTop,
      damage: damage,
      id: id,
      height: height,
      width: width,
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
    required double width,
    required double height,
    dynamic id,
    double speed = 150,
    double damage = 1,
    Direction? direction,
    bool withCollision = true,
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
