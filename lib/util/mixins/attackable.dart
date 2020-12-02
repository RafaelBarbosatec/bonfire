import 'package:bonfire/base/game_component.dart';
import 'package:flutter/widgets.dart';

enum ReceivesAttackFromEnum { ALL, ENEMY, PLAYER }
mixin Attackable on GameComponent {
  ReceivesAttackFromEnum receivesAttackFrom = ReceivesAttackFromEnum.ALL;
  void receiveDamage(double damage, dynamic from);
  Rect rectAttackable();

  bool receivesAttackFromPlayer() =>
      receivesAttackFrom == ReceivesAttackFromEnum.ALL || receivesAttackFrom == ReceivesAttackFromEnum.PLAYER;
  bool receivesAttackFromEnemy() =>
      receivesAttackFrom == ReceivesAttackFromEnum.ALL || receivesAttackFrom == ReceivesAttackFromEnum.ENEMY;
}
