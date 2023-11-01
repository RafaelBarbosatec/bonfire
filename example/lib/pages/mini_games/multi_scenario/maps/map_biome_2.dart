import 'package:bonfire/bonfire.dart';
import 'package:example/pages/mini_games/multi_scenario/multi_scenario.dart';
import 'package:example/pages/mini_games/multi_scenario/player/game_player.dart';
import 'package:example/pages/mini_games/multi_scenario/utils/constants/game_consts.dart';
import 'package:example/pages/mini_games/multi_scenario/utils/enums/map_id_enum.dart';
import 'package:example/pages/mini_games/multi_scenario/utils/enums/show_in_enum.dart';
import 'package:example/pages/mini_games/multi_scenario/utils/sensors/exit_map_sensor.dart';
import 'package:example/pages/mini_games/random_map/player/pirate_sprite_sheet.dart';
import 'package:flutter/material.dart';

class MapBiome2 extends StatelessWidget {
  final ShowInEnum showInEnum;

  const MapBiome2({
    Key? key,
    required this.showInEnum,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BonfireWidget(
      joystick: Joystick(
        keyboardConfig: KeyboardConfig(),
        directional: JoystickDirectional(),
      ),
      player: GamePlayer(
        _getInitPosition(),
        PirateSpriteSheet.getAnimation(),
        initDirection: showInEnum.direction,
      ),
      map: WorldMapByTiled(
        MultiScenarioAssets.mapBiome2,
        forceTileSize: Vector2.all(defaultTileSize),
        objectsBuilder: {
          'sensorLeft': (p) => ExitMapSensor(
                'sensorLeft',
                p.position,
                p.size,
                _exitMap,
              ),
        },
      ),
      cameraConfig: CameraConfig(
        moveOnlyMapArea: true,
        zoom: getZoomFromMaxVisibleTile(context, defaultTileSize, 20),
      ),
      progress: Container(
        width: double.maxFinite,
        height: double.maxFinite,
        color: Colors.black,
      ),
    );
  }

  Vector2 _getInitPosition() {
    switch (showInEnum) {
      case ShowInEnum.left:
        return Vector2(defaultTileSize * 1, defaultTileSize * 14);
      case ShowInEnum.right:
        return Vector2(defaultTileSize * 28, defaultTileSize * 12);
      case ShowInEnum.top:
        return Vector2.zero();
      case ShowInEnum.bottom:
        return Vector2.zero();
      default:
        return Vector2.zero();
    }
  }

  void _exitMap(String value) {
    if (value == 'sensorLeft') {
      selectMap(MapBiomeId.biome1);
    }
  }
}
