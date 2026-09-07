import 'package:bonfire/bonfire.dart';
import 'package:example/pages/player/simple/human.dart';
import 'package:example/shared/util/common_sprite_sheet.dart';
import 'package:flutter/material.dart';

/// Demonstrates [WorldMapInfiniteByTiled]: a small Tiled pattern
/// (`infinite_map.tmj`, 10x10 tiles) is repeated around the player as an
/// endless world. Walk in any direction — new chunks spawn seamlessly and
/// distant ones are unloaded (the origin chunk stays alive).
class InfiniteMapPage extends StatelessWidget {
  const InfiniteMapPage({super.key});

  @override
  Widget build(BuildContext context) {
    const tileSize = 16.0;
    return BonfireWidget(
      map: WorldMapInfiniteByTiled(
        WorldMapReader.fromAsset('tiled/simple_topdown/infinite_map.tmj'),
        // Try InfiniteWorldMapType.horizontal / vertical to see a world
        // that only expands on one axis.
        type: InfiniteWorldMapType.open,
        objectsBuilder: {
          'column': (props) => _InfiniteColumn(
                props.position,
              ),
        },
      ),
      playerControllers: [
        Joystick(
          directional: JoystickDirectional(),
        ),
        Keyboard(),
      ],
      player: HumanPlayer(
        position: Vector2(tileSize * 5, tileSize * 5),
      ),
      cameraConfig: CameraConfig(
        zoom: getZoomFromMaxVisibleTile(context, tileSize, 15),
        moveOnlyMapArea: true,
      ),
      backgroundColor: const Color(0xFF1b2838),
    );
  }
}

/// A column placed by the object layer of the pattern. It is recreated for
/// every chunk, which makes the chunk repetition visible while walking.
class _InfiniteColumn extends GameDecoration {
  _InfiniteColumn(Vector2 position)
      : super.withSprite(
          sprite: CommonSpriteSheet.columnSprite,
          position: position,
          size: Vector2(16, 48),
        );

  @override
  Future<void> onLoad() {
    add(
      RectangleHitbox(
        isSolid: true,
        size: Vector2(12, 16),
        position: Vector2(2, 30),
      ),
    );
    return super.onLoad();
  }
}
