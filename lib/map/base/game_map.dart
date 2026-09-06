import 'package:bonfire/bonfire.dart';
import 'package:bonfire/map/base/layer.dart';

export 'package:bonfire/map/base/tile_layer_component.dart';

abstract class GameMap extends GameComponent with WithShader {
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

  /// World keeps expanding around the player (used by infinite maps).
  bool get isWorldInfinite => false;

  /// Pixels added to the Y priority of game components so they keep rendering
  /// above the tile map when the world extends to negative coordinates.
  /// Defaults to 0 for regular maps (origin at 0+).
  double get renderPriorityOffsetY => 0;

  /// Area where the camera center is allowed to move when
  /// `CameraConfig.moveOnlyMapArea` is enabled. Infinite maps override this
  /// to release the axis(es) that never end.
  Shape? getMoveAreaBounds(Rect visibleWorldRect) {
    final rect = getMapRect().deflatexy(
      visibleWorldRect.width / 2,
      visibleWorldRect.height / 2,
    );
    return Rectangle.fromRect(rect);
  }

  @override
  int get priority => LayerPriority.MAP;

  @override
  bool get isVisible => true;

  Iterable<TileLayerComponent> get layersComponent;
}
