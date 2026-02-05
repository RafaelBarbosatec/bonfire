import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:platform_game/components/fox_player.dart';
import 'package:platform_game/components/frog_enemy.dart';
import 'package:platform_game/components/gem_decoration.dart';
import 'package:platform_game/util/platform_game_controller.dart';

class PlatformGame extends StatefulWidget {
  static const double tileSize = 16.0;
  const PlatformGame({super.key});

  @override
  State<PlatformGame> createState() => _PlatformGameState();
}

class _PlatformGameState extends State<PlatformGame> {
  Key _gameKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return BonfireWidget(
      key: _gameKey,
      map: WorldMapByTiled(
        WorldMapReader.fromAsset('platform_map.tmj'),
        objectsBuilder: {
          'frog': (properties) => FrogEnemy(position: properties.position),
          'gem': (properties) => GemDecoration(position: properties.position),
        },
      ),
      playerControllers: [
        Joystick(
          directional: JoystickDirectional(color: Colors.green),
          actions: [
            JoystickAction(
              actionId: 1,
              margin: const EdgeInsets.all(50),
              color: Colors.green,
            ),
          ],
        ),
        Keyboard(
          config: KeyboardConfig(acceptedKeys: [LogicalKeyboardKey.space]),
        ),
      ],
      components: [PlatformGameController(reset: reset)],
      backgroundColor: const Color(0xFF2fbdff),
      globalForces: GlobalForcesSettings(gravity: Vector2(0, 300)),
      cameraConfig: CameraConfig(
        moveOnlyMapArea: true,
        zoom: getZoomFromMaxVisibleTile(
          context,
          PlatformGame.tileSize,
          20,
          orientation: Orientation.landscape,
        ),
        speed: 4,
      ),
      player: FoxPlayer(
        position: Vector2(
          50 * PlatformGame.tileSize,
          3 * PlatformGame.tileSize,
        ),
      ),
    );
  }

  void reset() {
    setState(() {
      _gameKey = UniqueKey();
    });
  }
}
