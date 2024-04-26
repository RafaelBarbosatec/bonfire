import 'package:bonfire/map/base/layer.dart';
import 'package:bonfire/map/base/tile_layer_component.dart';

abstract class LayerMapper {
  static TileLayerComponent toLayerComponent(Layer layer) {
    return TileLayerComponent(
      id: layer.id ?? 0,
      tiles: layer.tiles,
      position: layer.position,
      visible: layer.visible,
      name: layer.name,
      layerClass: layer.layerClass,
      opacity: layer.opacity,
      properties: layer.properties,
      priority: layer.priority,
    );
  }
}
