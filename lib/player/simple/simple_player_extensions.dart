import 'package:bonfire/bonfire.dart';
import 'package:bonfire/lighting/lighting_config.dart';
import 'package:bonfire/player/extensions.dart';
import 'package:bonfire/player/simple/simple_player.dart';
import 'package:bonfire/util/collision/object_collision.dart';
import 'package:bonfire/util/direction.dart';
import 'package:flutter/widgets.dart';

extension SimplePlayerExtensions on SimplePlayer {
  void simpleAttackMelee({
    SpriteAnimation animationRight,
    SpriteAnimation animationBottom,
    SpriteAnimation animationLeft,
    SpriteAnimation animationTop,
    @required double damage,
    dynamic id,
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
    @required SpriteAnimation animationRight,
    @required SpriteAnimation animationLeft,
    @required SpriteAnimation animationTop,
    @required SpriteAnimation animationBottom,
    SpriteAnimation animationDestroy,
    @required double width,
    @required double height,
    dynamic id,
    double speed = 150,
    double damage = 1,
    Direction direction,
    bool withCollision = true,
    VoidCallback destroy,
    CollisionConfig collision,
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
