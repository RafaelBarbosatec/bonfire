import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/collision/object_collision.dart';
import 'package:bonfire/map/tile/tile.dart';
import 'package:bonfire/map/tile/tile_model.dart';
import 'package:bonfire/util/priority_layer.dart';
import 'package:flame/extensions.dart';

abstract class MapGame extends GameComponent {
  List<TileModel> tiles;
  Size? mapSize;
  Vector2? mapStartPosition;
  double tileSizeToUpdate;
  List<Tile> childrenTiles = [];

  MapGame(this.tiles, {this.tileSizeToUpdate = 0});

  Iterable<Tile> getRendered();

  Iterable<ObjectCollision> getCollisionsRendered();
  Iterable<ObjectCollision> getCollisions();

  Future<void> updateTiles(List<TileModel> map);

  Size getMapSize();

  void removeTile(String id);
  Future addTile(TileModel tileModel);

  void setLinePath(List<Offset> linePath, Color color, double strokeWidth) {}

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
