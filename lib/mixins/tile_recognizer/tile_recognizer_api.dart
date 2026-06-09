import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/map/base/tile_component.dart';
import 'package:bonfire/util/extensions/game_component_extensions.dart';

/// API for querying map tile information below the component.
class TileRecognizerApi {
  final GameComponent comp;

  TileRecognizerApi(this.comp);

  /// Returns the type of the first map tile below the component.
  String? tileTypeBelow() {
    final list = tileTypeListBelow();
    if (list.isNotEmpty) {
      return list.first;
    }
    return null;
  }

  /// Returns all tile types below the component.
  List<String> tileTypeListBelow() {
    if (!comp.hasGameRef) {
      return [];
    }
    final map = comp.gameRef.map;
    if (map.getRenderedTiles().isNotEmpty) {
      return tileListBelow().map<String>((e) => e.tileClass!).toList();
    }
    return [];
  }

  /// Returns the properties of the first map tile below the component.
  Map<String, dynamic>? tilePropertiesBelow() {
    final list = tilePropertiesListBelow();
    if (list?.isNotEmpty == true) {
      return list?.first;
    }
    return null;
  }

  /// Returns all tile properties below the component.
  List<Map<String, dynamic>>? tilePropertiesListBelow() {
    if (!comp.hasGameRef) {
      return null;
    }
    final map = comp.gameRef.map;
    if (map.layers.isNotEmpty) {
      return tileListBelow()
          .map<Map<String, dynamic>>((e) => e.properties!)
          .toList();
    }
    return null;
  }

  /// Returns all tile components below the component.
  Iterable<TileComponent> tileListBelow() {
    if (!comp.hasGameRef) {
      return [];
    }
    final map = comp.gameRef.map;
    if (map.layers.isNotEmpty) {
      return map.getRenderedTiles().where((element) {
        return element.overlaps(comp.rectCollision) &&
            (element.properties != null);
      });
    }
    return [];
  }
}
