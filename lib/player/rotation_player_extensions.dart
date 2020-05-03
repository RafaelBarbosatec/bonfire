import 'package:bonfire/player/rotation_player.dart';
import 'package:bonfire/util/collision/collision.dart';
import 'package:bonfire/util/objects/flying_attack_angle_object.dart';
import 'package:flame/animation.dart' as FlameAnimation;
import 'package:flame/position.dart';
import 'package:flutter/widgets.dart';

extension RotationPlayerExtensions on RotationPlayer {
  void simpleAttackRange({
    @required FlameAnimation.Animation animationTop,
    @required FlameAnimation.Animation animationDestroy,
    @required double width,
    @required double height,
    double speed = 150,
    double damage = 1,
    bool withCollision = true,
    VoidCallback destroy,
    Collision collision,
  }) {
    if (isDead) return;
    gameRef.add(FlyingAttackAngleObject(
      initPosition: Position(positionInWorld.left, positionInWorld.top),
      radAngle: this.currentRadAngle,
      width: width,
      height: height,
      damage: damage,
      speed: speed,
      damageInPlayer: false,
      collision: collision,
      withCollision: withCollision,
      damageInEnemy: true,
      destroyedObject: destroy,
      flyAnimation: animationTop,
      destroyAnimation: animationDestroy,
    ));
  }
}
