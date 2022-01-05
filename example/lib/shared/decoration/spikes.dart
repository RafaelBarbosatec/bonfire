import 'package:bonfire/bonfire.dart';
import 'package:example/manual_map/dungeon_map.dart';
import 'package:example/shared/util/common_sprite_sheet.dart';

class Spikes extends GameDecoration with Sensor {
  double dt = 0;

  Spikes(Vector2 position)
      : super.withSprite(
          sprite: CommonSpriteSheet.spikesSprite,
          position: position,
          size: Vector2.all(DungeonMap.tileSize / 1.5),
        ) {
    setupSensorArea(intervalCheck: 500);
  }

  @override
  void update(double dt) {
    this.dt = dt;
    super.update(dt);
  }

  @override
  void onContact(GameComponent component) {
    if (component is Attackable) {
      component.receiveDamage(10, 1);
    }
  }

  @override
  int get priority => LayerPriority.MAP + 1;
}
