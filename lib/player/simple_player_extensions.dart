import 'package:bonfire/player/extensions.dart';
import 'package:bonfire/player/simple_player.dart';
import 'package:bonfire/util/collision/collision.dart';
import 'package:bonfire/util/direction.dart';
import 'package:bonfire/util/lighting/lighting_config.dart';
import 'package:flame/animation.dart' as FlameAnimation;
import 'package:flutter/widgets.dart';

extension SimplePlayerExtensions on SimplePlayer {
  void simpleAttackMelee({
    FlameAnimation.Animation animationRight,
    FlameAnimation.Animation animationBottom,
    FlameAnimation.Animation animationLeft,
    FlameAnimation.Animation animationTop,
    @required double damage,
    int id,
    Direction direction,
    double heightArea = 32,
    double widthArea = 32,
    bool withPush = true,
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
      heightArea: heightArea,
      widthArea: widthArea,
      withPush: withPush,
    );
  }

  void simpleAttackRange({
    @required FlameAnimation.Animation animationRight,
    @required FlameAnimation.Animation animationLeft,
    @required FlameAnimation.Animation animationTop,
    @required FlameAnimation.Animation animationBottom,
    @required FlameAnimation.Animation animationDestroy,
    @required double width,
    @required double height,
    int id,
    double speed = 150,
    double damage = 1,
    Direction direction,
    bool withCollision = true,
    VoidCallback destroy,
    Collision collision,
    LightingConfig lightingConfig,
  }) {
    Direction attackDirection = direction ?? this.lastDirection;
    this.simpleAttackRangeByDirection(
      direction: attackDirection,
      animationRight: animationRight,
      animationLeft: animationLeft,
      animationTop: animationTop,
      animationBottom: animationBottom,
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
