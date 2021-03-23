import 'dart:async' as async;

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/collision/object_collision.dart';
import 'package:example/map/dungeon_map.dart';

class Spikes extends GameDecoration with Sensor {
  async.Timer timer;

  bool isTick = false;

  Spikes(Vector2 position)
      : super.futureSprite(
          Sprite.load('itens/spikes.png'),
          position: position,
          width: DungeonMap.tileSize / 1.5,
          height: DungeonMap.tileSize / 1.5,
        );

  @override
  void onContact(ObjectCollision collision) {
    if (timer == null) {
      if (collision is Attackable) {
        (collision as Attackable).receiveDamage(10, 1);
        timer = async.Timer(Duration(milliseconds: 500), () {
          timer = null;
        });
      }
    }
  }
}
