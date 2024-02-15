import 'package:bonfire/map/world_map.dart';

class EmptyWorldMap extends WorldMap {
  EmptyWorldMap({double tileSizeToUpdate = 0})
      : super([], tileSizeToUpdate: tileSizeToUpdate);
}
