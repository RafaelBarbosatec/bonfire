import 'package:bonfire/bonfire.dart';
import 'package:example/pages/mini_games/manual_map/dungeon_map.dart';

import 'goblin.dart';

///
/// Created by
///
/// ─▄▀─▄▀
/// ──▀──▀
/// █▀▀▀▀▀█▄
/// █░░░░░█─█
/// ▀▄▄▄▄▄▀▀
///
/// Rafaelbarbosatec
/// on 03/03/22
class GoblinController extends StateController<Goblin> {
  double attack = 20;
  bool enableBehaviors = true;

  @override
  void update(double dt, Goblin component) {
    if (!enableBehaviors) return;

    if (!gameRef.sceneBuilderStatus.isRunning) {
      component.seePlayer(
        radiusVision: DungeonMap.tileSize * 3,
        observed: (p) {
          if (component.distance(p) <= DungeonMap.tileSize * 2) {
            component.moveTowardsTarget(
              target: p,
              close: () {
                component.execAttack(attack);
              },
            );
          } else {
            component.seeAndMoveToAttackRange(
              minDistanceFromPlayer: DungeonMap.tileSize * 2,
              positioned: (p) {
                component.execAttackRange(attack);
              },
              radiusVision: DungeonMap.tileSize * 3,
            );
          }
        },
        notObserved: () {
          component.runRandomMovement(
            dt,
            speed: component.speed / 2,
            maxDistance: (DungeonMap.tileSize * 3).toInt(),
          );
        },
      );
    }
  }
}
