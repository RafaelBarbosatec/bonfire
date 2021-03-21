import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/util/collision/object_collision.dart';
import 'package:flutter/widgets.dart';

enum ReceivesAttackFromEnum { ALL, ENEMY, PLAYER }
enum AttackFromEnum { ENEMY, PLAYER }

mixin Attackable on GameComponent {
  /// Used to define which type of component can be damaged
  ReceivesAttackFromEnum receivesAttackFrom = ReceivesAttackFromEnum.ALL;

  void receiveDamage(double damage, dynamic from);

  Rect rectAttackable() => this is ObjectCollision
      ? (this as ObjectCollision).rectCollision
      : position;

  bool receivesAttackFromPlayer() {
    return receivesAttackFrom == ReceivesAttackFromEnum.ALL ||
        receivesAttackFrom == ReceivesAttackFromEnum.PLAYER;
  }

  bool receivesAttackFromEnemy() {
    return receivesAttackFrom == ReceivesAttackFromEnum.ALL ||
        receivesAttackFrom == ReceivesAttackFromEnum.ENEMY;
  }
}
