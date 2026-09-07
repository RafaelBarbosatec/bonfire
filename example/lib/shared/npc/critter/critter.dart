import 'package:bonfire/bonfire.dart';
import 'package:example/pages/mini_games/manual_map/dungeon_map.dart';
import 'package:example/shared/util/critter_sprite_sheet.dart';

class Critter extends SimpleNpc with WithCollision, WithRandomMovement {
  bool enableBehaviors = true;
  Critter(Vector2 position)
      : super(
          animation: CritterSpriteSheet.simpleDirectionAnimation,
          position: position,
          size: Vector2.all(DungeonMap.tileSize * 0.8),
          speed: DungeonMap.tileSize,
        ) {
    randomMovement.setup(
      speed: speed / 10,
      maxDistance: (DungeonMap.tileSize),
    );
  }

  @override
  void update(double dt) {
    if (!enableBehaviors) return;

    vision.seeAndMoveToPlayer(
      closePlayer: (player) {},
      observed: () {},
      radiusVision: DungeonMap.tileSize * 1.5,
      notObserved: () {
        randomMovement.run(
          dt,
        );
        return false;
      },
    );
    super.update(dt);
  }

  @override
  Future<void> onLoad() {
    add(
      RectangleHitbox(
        size: Vector2(
          DungeonMap.tileSize * 0.4,
          DungeonMap.tileSize * 0.4,
        ),
        position: Vector2(
          DungeonMap.tileSize * 0.2,
          DungeonMap.tileSize * 0.2,
        ),
      ),
    );
    return super.onLoad();
  }
}
