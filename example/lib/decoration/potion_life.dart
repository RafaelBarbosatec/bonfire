import 'dart:async' as async;

import 'package:bonfire/bonfire.dart';
import 'package:example/manual_map/dungeon_map.dart';
import 'package:example/util/common_sprite_sheet.dart';

class PotionLife extends GameDecoration with Sensor {
  final double life;
  double _lifeDistributed = 0;

  PotionLife(Vector2 position, this.life)
      : super.withSprite(
          CommonSpriteSheet.potionLifeSprite,
          position: position,
          width: DungeonMap.tileSize * 0.5,
          height: DungeonMap.tileSize * 0.5,
        );

  @override
  void onContact(GameComponent collision) {
    if (collision is Player) {
      async.Timer.periodic(Duration(milliseconds: 100), (timer) {
        if (_lifeDistributed >= life) {
          timer.cancel();
        } else {
          _lifeDistributed += 2;
          gameRef.player?.addLife(5);
        }
      });
      remove();
    }
  }
}
