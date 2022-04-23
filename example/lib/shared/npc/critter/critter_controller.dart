import 'package:bonfire/bonfire.dart';
import 'package:example/manual_map/dungeon_map.dart';

import 'critter.dart';

class CritterController extends StateController<Critter> {
  bool enableBehaviors = true;
  @override
  void update(double dt, Critter component) {
    if (!enableBehaviors) return;

    component.seeAndMoveToPlayer(
      closePlayer: (player) {},
      observed: () {},
      radiusVision: DungeonMap.tileSize * 1.5,
      notObserved: () {
        component.runRandomMovement(
          dt,
          speed: component.speed / 10,
          maxDistance: (DungeonMap.tileSize).toInt(),
        );
      },
    );
  }
}
