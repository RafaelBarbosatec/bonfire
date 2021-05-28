import 'dart:async' as async;

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/priority_layer.dart';
import 'package:example/manual_map/dungeon_map.dart';
import 'package:example/util/common_sprite_sheet.dart';

class Spikes extends GameDecoration with Sensor {
  async.Timer? timer;

  bool isTick = false;

  Spikes(Vector2 position)
      : super.withSprite(
          CommonSpriteSheet.spikesSprite,
          position: position,
          width: DungeonMap.tileSize / 1.5,
          height: DungeonMap.tileSize / 1.5,
        );

  @override
  void onContact(GameComponent component) {
    if (timer == null) {
      if (component is Attackable) {
        component.receiveDamage(10, 1);
        timer = async.Timer(Duration(milliseconds: 500), () {
          timer = null;
        });
      }
    }
  }

  @override
  int get priority => LayerPriority.MAP + 1;
}
