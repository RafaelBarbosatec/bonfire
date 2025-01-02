import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/map/base/tile_component.dart';
import 'package:bonfire/util/extensions/game_component_extensions.dart';

///
/// Created by
///
/// ─▄▀─▄▀
/// ──▀──▀
/// █▀▀▀▀▀█▄
/// █░░░░░█─█
/// ▀▄▄▄▄▄▀▀
///
/// Rafaelbarbosatec
/// on 16/05/22

mixin TileRecognizer on GameComponent {
  /// Method that checks what type map tile is currently
  String? tileTypeBelow() {
    final list = tileTypeListBelow();
    if (list.isNotEmpty) {
      return list.first;
    }
    return null;
  }

  /// Method that checks what types map tile is currently
  List<String> tileTypeListBelow() {
    if (!hasGameRef) {
      return [];
    }
    final map = gameRef.map;
    if (map.getRenderedTiles().isNotEmpty) {
      return tileListBelow().map<String>((e) => e.tileClass!).toList();
    }
    return [];
  }

  /// Method that checks what properties map tile is currently
  Map<String, dynamic>? tilePropertiesBelow() {
    final list = tilePropertiesListBelow();
    if (list?.isNotEmpty == true) {
      return list?.first;
    }

    return null;
  }

  /// Method that checks what properties list map tile is currently
  List<Map<String, dynamic>>? tilePropertiesListBelow() {
    if (!hasGameRef) {
      return null;
    }
    final map = gameRef.map;
    if (map.layers.isNotEmpty) {
      return tileListBelow()
          .map<Map<String, dynamic>>((e) => e.properties!)
          .toList();
    }
    return null;
  }

  /// Method that checks what map tiles is below
  Iterable<TileComponent> tileListBelow() {
    if (!hasGameRef) {
      return [];
    }
    final map = gameRef.map;
    if (map.layers.isNotEmpty) {
      return map.getRenderedTiles().where((element) {
        return element.overlaps(rectCollision) && (element.properties != null);
      });
    }
    return [];
  }
}
