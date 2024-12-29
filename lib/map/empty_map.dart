import 'package:bonfire/bonfire.dart';
import 'package:bonfire/map/base/layer.dart';

class EmptyWorldMap extends WorldMap {
  EmptyWorldMap({double tileSizeToUpdate = 0, Vector2? size})
      : super(
          [
            Layer(
              id: 0,
              tiles: [
                if (size != null)
                  Tile(x: size.x, y: size.y, width: 1, height: 1),
              ],
            ),
          ],
          tileSizeToUpdate: tileSizeToUpdate,
        );
}
