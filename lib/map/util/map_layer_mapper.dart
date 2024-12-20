import 'package:bonfire/bonfire.dart';
import 'package:bonfire/map/base/layer.dart';
import 'package:tiledjsonreader/map/layer/map_layer.dart';
import 'package:tiledjsonreader/map/layer/objects.dart';

abstract class MapLayerMapper {
  static Layer toLayer(MapLayer layer, int priority) {
    return Layer(
      id: layer.id,
      layerClass: layer.layerClass,
      name: layer.name,
      opacity: layer.opacity ?? 1,
      visible: layer.visible ?? true,
      priority: priority,
      position: Vector2(
        layer.x ?? 0,
        layer.y ?? 0,
      ),
      offset: Vector2(
        layer.offsetX ?? 0,
        layer.offsetY ?? 0,
      ),
      properties: extractOtherProperties(layer.properties),
      tiles: [],
    );
  }

  static Map<String, dynamic> extractOtherProperties(
    List<Property>? properties,
  ) {
    final map = <String, dynamic>{};

    for (final element in properties ?? const <Property>[]) {
      if (element.value != null && element.name != null) {
        map[element.name!] = element.value;
      }
    }
    return map;
  }
}
