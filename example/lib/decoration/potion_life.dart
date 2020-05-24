import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:example/map/dungeon_map.dart';
import 'package:flame/position.dart';

class PotionLife extends GameDecoration {
  final Position initPosition;
  final double life;
  double _lifeDistributed = 0;

  PotionLife(this.initPosition, this.life)
      : super.sprite(
          Sprite('itens/potion_life.png'),
          initPosition: initPosition,
          width: DungeonMap.tileSize * 0.5,
          height: DungeonMap.tileSize * 0.5,
        );

  @override
  void update(double dt) {
    super.update(dt);
    if (position.overlaps(gameRef.player.position)) {
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
