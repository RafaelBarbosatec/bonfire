import 'package:bonfire/bonfire.dart';
import 'package:example/pages/mini_games/manual_map/dungeon_map.dart';
import 'package:example/shared/util/common_sprite_sheet.dart';

class PotionLife extends GameDecoration with Sensor<Player>, Movement {
  final double life;
  double _lifeDistributed = 0;

  PotionLife(Vector2 position, this.life, {Vector2? size})
      : super.withSprite(
          sprite: CommonSpriteSheet.potionLifeSprite,
          position: position,
          size: size ?? Vector2.all(DungeonMap.tileSize * 0.5),
        );

  @override
  void onContact(Player component) {
    generateValues(
      const Duration(seconds: 1),
      onChange: (value) {
        if (_lifeDistributed < life) {
          double newLife = life * value - _lifeDistributed;
          _lifeDistributed += newLife;
          component.addLife(newLife.roundToDouble());
        }
      },
    );
    removeFromParent();
    super.onContact(component);
  }

  @override
  void onMount() {
    gameRef.generateValues(
      const Duration(seconds: 1),
      onChange: (value) {
        spriteOffset = Vector2(0, 5 * -value);
      },
      infinite: true,
    );
    super.onMount();
  }
}
