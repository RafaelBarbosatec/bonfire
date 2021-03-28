import 'dart:ui';

import 'package:bonfire/base/bonfire_game.dart';
import 'package:bonfire/map/tile/tile.dart';
import 'package:bonfire/util/priority_layer.dart';
import 'package:flame/components/component.dart';
import 'package:flame/components/mixins/has_game_ref.dart';
import 'package:flame/position.dart';

abstract class MapGame extends Component with HasGameRef<BonfireGame> {
  Iterable<Tile> tiles;
  Size mapSize;
  Position mapStartPosition;

  MapGame(this.tiles);

  Iterable<Tile> getRendered();

  Iterable<Tile> getCollisionsRendered();
  Iterable<Tile> getCollisions();

  void updateTiles(Iterable<Tile> map);

  Size getMapSize();

  @override
  int priority() => PriorityLayer.MAP;
}
