import 'package:turn_game/util/player_turn.dart';
import 'package:turn_game/util/player_enemy.dart';

abstract class PlayerAlly extends PlayerTurn {
  PlayerAlly({
    required super.position,
    required super.size,
    required super.animation,
  });

  @override
  void doAttackChar(PlayerTurn char) {
    if (char is PlayerEnemy) {
      doAttackEnemy(char);
    }
  }

  void doAttackEnemy(PlayerEnemy enemy);
}
