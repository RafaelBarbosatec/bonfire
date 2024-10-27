import 'package:bonfire/bonfire.dart';
import 'package:example/pages/mini_games/random_map/player/pirate_sprite_sheet.dart';
import 'package:flutter/material.dart';

import 'components/game_player.dart';
import 'maps.dart';
import 'utils/constants/game_consts.dart';

class MultiScenario extends StatelessWidget {
  const MultiScenario({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MapNavigator(
      maps: Maps.maps,
      builder: (context, arguments, map) {
        MapArguments? mapArguments = arguments as MapArguments?;
        return BonfireWidget(
          playerControllers: [
            Joystick(
              directional: JoystickDirectional(),
            ),
          ],
          player: GamePlayer(
            (mapArguments?.playerPosition ?? Vector2(2, 11)) * defaultTileSize,
            PirateSpriteSheet.getAnimation(),
            initDirection: mapArguments?.playerDirection ?? Direction.right,
          ),
          map: map.map,
          cameraConfig: CameraConfig(
            moveOnlyMapArea: true,
            zoom: getZoomFromMaxVisibleTile(context, defaultTileSize, 20),
          ),
        );
      },
    );
  }
}
