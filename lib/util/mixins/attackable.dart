import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/collision/object_collision.dart';
import 'package:bonfire/util/vector2rect.dart';

enum ReceivesAttackFromEnum { ALL, ENEMY, PLAYER }
enum AttackFromEnum { ENEMY, PLAYER }

mixin Attackable on GameComponent {
  /// Used to define which type of component can be damaged
  ReceivesAttackFromEnum receivesAttackFrom = ReceivesAttackFromEnum.ALL;

  void receiveDamage(double damage, dynamic from);

  Vector2Rect rectAttackable() => this.isObjectCollision()
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
