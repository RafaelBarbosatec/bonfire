import 'dart:ui';

import 'package:bonfire/base/bonfire_game.dart';
import 'package:bonfire/map/tile/tile.dart';
import 'package:bonfire/util/priority_layer.dart';
import 'package:flame/components.dart';

abstract class MapGame extends Component with HasGameRef<BonfireGame> {
  Iterable<Tile> tiles;
  Size? mapSize;
  Vector2? mapStartPosition;

  MapGame(this.tiles);

  Iterable<Tile> getRendered();

  Iterable<Tile> getCollisionsRendered();
  Iterable<Tile> getCollisions();

  Future<void> updateTiles(Iterable<Tile> map);

  Size getMapSize();

  @override
  Future<void> onLoad() {
    return Future.forEach<Tile>(tiles, (element) => element.onLoad());
  }

  @override
  int get priority => LayerPriority.MAP;
}
