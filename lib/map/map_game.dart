import 'dart:ui';

import 'package:bonfire/base/bonfire_game.dart';
import 'package:bonfire/collision/object_collision.dart';
import 'package:bonfire/map/tile/tile.dart';
import 'package:bonfire/util/priority_layer.dart';
import 'package:flame/components.dart';

abstract class MapGame extends Component with HasGameRef<BonfireGame> {
  Iterable<Tile> tiles;
  Size? mapSize;
  Vector2? mapStartPosition;

  MapGame(this.tiles);

  Iterable<Tile> getRendered();

  Iterable<ObjectCollision> getCollisionsRendered();
  Iterable<ObjectCollision> getCollisions();

  Future<void> updateTiles(Iterable<Tile> map);

  Size getMapSize();

  @override
  Future<void> onLoad() {
    return Future.forEach<Tile>(tiles, (element) => element.onLoad());
  }

  void setLinePath(List<Offset> linePath, Color color, double strokeWidth) {}

  @override
  int get priority => LayerPriority.MAP;
}
