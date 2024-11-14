import 'package:bonfire/bonfire.dart';
import 'package:bonfire/map/base/layer.dart';

export 'package:bonfire/map/base/tile_layer_component.dart';

abstract class GameMap extends GameComponent with UseShader {
  List<Layer> layers;
  double sizeToUpdate;
  double tileSize = 0.0;

  GameMap(this.layers, {this.sizeToUpdate = 0});

  Iterable<TileComponent> getRenderedTiles();

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

  void removeLayer(int id);
  Future addLayer(Layer layer);
  Future<void> updateLayers(List<Layer> layers);

  @override
  int get priority => LayerPriority.MAP;

  @override
  bool get isVisible => true;

  Iterable<TileLayerComponent> get layersComponent;
}
