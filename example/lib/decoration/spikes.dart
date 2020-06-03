import 'package:bonfire/bonfire.dart';
import 'package:example/map/dungeon_map.dart';
import 'package:flame/position.dart';

const TIME_BETWEEN_HITS = 1.5;

class Spikes extends GameDecoration {
  final Position initPosition;
  double _timeSinceLastHit = 0;

  Spikes(this.initPosition)
      : super.sprite(
          Sprite('itens/spikes.png'),
          initPosition: initPosition,
          width: DungeonMap.tileSize / 1.5,
          height: DungeonMap.tileSize / 1.5,
          isSensor: true,
          collision: Collision(
            width: DungeonMap.tileSize / 2,
            height: DungeonMap.tileSize / 2,
            align: CollisionAlign.CENTER,
          ),
        );

  @override
  void update(double dt) {
    if (_timeSinceLastHit > 0) {
      _timeSinceLastHit -= dt;
    }
  }

  @override
  void onContact(collision) {
    // only allows hit player after 1.5s from last hit
    if (_timeSinceLastHit > 0) return;

    // only triggers on collision with player
    if (collision.runtimeType.toString() == 'Knight') {
      _timeSinceLastHit = TIME_BETWEEN_HITS;
      gameRef.player.receiveDamage(10, 1);
    }
  }
}
