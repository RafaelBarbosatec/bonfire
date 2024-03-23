import 'package:bonfire/bonfire.dart';

class EmptyWorldMap extends WorldMap {
  EmptyWorldMap({double tileSizeToUpdate = 0, Vector2? size})
      : super([
          if (size != null) TileModel(x: size.x, y: size.y, width: 1, height: 1)
        ], tileSizeToUpdate: tileSizeToUpdate);
}
