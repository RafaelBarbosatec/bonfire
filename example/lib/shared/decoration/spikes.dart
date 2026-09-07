import 'package:bonfire/bonfire.dart';
import 'package:example/pages/mini_games/manual_map/dungeon_map.dart';
import 'package:example/shared/util/common_sprite_sheet.dart';

class Spikes extends GameDecoration with WithSensor<WithLife> {
  Spikes(Vector2 position, {Vector2? size})
      : super.withSprite(
          sprite: CommonSpriteSheet.spikesSprite,
          position: position,
          size: size ?? Vector2.all(DungeonMap.tileSize / 1.5),
        ) {
    sensor.setup(interval: 500);
    sensor.onContactListener(_onContact);
  }

  void _onContact(WithLife component) {
    if (component is Player) {
      component.life.handleAttack(AttackOriginEnum.ENEMY, 10, 1);
    } else {
      component.life.handleAttack(AttackOriginEnum.PLAYER_OR_ALLY, 10, 1);
    }
  }
}
