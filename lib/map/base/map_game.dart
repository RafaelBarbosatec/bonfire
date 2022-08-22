import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/collision/object_collision.dart';
import 'package:bonfire/map/base/tile.dart';
import 'package:bonfire/map/base/tile_model.dart';
import 'package:bonfire/util/priority_layer.dart';
import 'package:flame/extensions.dart';

abstract class GameMap extends GameComponent {
  List<TileModel> tiles;
  double tileSizeToUpdate;
  List<Tile> childrenTiles = [];

  GameMap(this.tiles, {this.tileSizeToUpdate = 0});

  Iterable<Tile> getRendered();

  Iterable<ObjectCollision> getCollisionsRendered();
  Iterable<ObjectCollision> getCollisions();

  Future<void> updateTiles(List<TileModel> map);

  Size getMapSize();
  Vector2 getStartPosition();
  Vector2 getGridSize();

  void removeTile(String id);
  Future addTile(TileModel tileModel);

  @override
  int get priority => LayerPriority.MAP;

  void renderDebugMode(Canvas canvas) {
    super.renderDebugMode(canvas);
    for (Tile t in getRendered()) {
      t.renderDebugMode(canvas);
    }
  }

  @override
  bool get isVisible => true;
}
