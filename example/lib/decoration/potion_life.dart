import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/collision/object_collision.dart';
import 'package:example/map/dungeon_map.dart';
import 'package:flame/position.dart';

class PotionLife extends GameDecoration with Sensor {
  final Position initPosition;
  final double life;
  double _lifeDistributed = 0;

  PotionLife(this.initPosition, this.life)
      : super.sprite(
          Sprite('itens/potion_life.png'),
          position: initPosition,
          width: DungeonMap.tileSize * 0.5,
          height: DungeonMap.tileSize * 0.5,
        );

  @override
  void onContact(ObjectCollision collision) {
    if (collision is Player) {
      Timer.periodic(Duration(milliseconds: 100), (timer) {
        if (_lifeDistributed >= life) {
          timer.cancel();
        } else {
          _lifeDistributed += 2;
          gameRef.player.addLife(5);
        }
      });
      remove();
    }
  }
}
