import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:example/pages/mini_games/manual_map/dungeon_map.dart';
import 'package:example/shared/enemy/goblin.dart';
import 'package:example/shared/util/common_sprite_sheet.dart';

class GameManualController extends GameComponent {
  @override
  void update(double dt) {
    if (checkInterval('check_living_enemies', 500, dt)) {
      if (gameRef.livingEnemies().length < 2) {
        _addEnemyInWorld();
      }
    }
    super.update(dt);
  }

  void _addEnemyInWorld() {
    double x = DungeonMap.tileSize * (4 + Random().nextInt(25));
    double y = DungeonMap.tileSize * (5 + Random().nextInt(3));

    final goblin = Goblin(Vector2(x, y));

    gameRef.add(
      AnimatedGameObject(
        animation: CommonSpriteSheet.smokeExplosion,
        size: Vector2.all(DungeonMap.tileSize),
        position: goblin.position,
        loop: false,
      ),
    );

    gameRef.add(
      goblin,
    );
  }
}
