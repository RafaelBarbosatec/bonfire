import 'package:bonfire/bonfire.dart';

export 'package:bonfire/map/base/tile_layer.dart';

abstract class GameMap extends GameComponent {
  List<TileLayer> layers;
  double sizeToUpdate;
  double tileSize = 0.0;

  GameMap(this.layers, {this.sizeToUpdate = 0});

  Iterable<Tile> getRendered();

  Future<void> updateLayers(List<TileLayer> layers);

  Vector2 getMapPosition();
  Vector2 getMapSize();
  void refreshMap();

  Rect getMapRect() {
    return Rect.fromLTWH(
      getMapPosition().x,
      getMapPosition().y,
      getMapSize().x,
      getMapSize().y,
    );
  }

  void removeLayer(String id);
  Future addLayer(TileLayer layer);

  @override
  int get priority => LayerPriority.MAP;

  @override
  bool get isVisible => true;
}
