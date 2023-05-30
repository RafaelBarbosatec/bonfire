import 'package:bonfire/bonfire.dart';
import 'package:example/platform/fox_player.dart';
import 'package:example/platform/frog_enemy.dart';
import 'package:example/platform/gem_decoration.dart';
import 'package:example/platform/platform_game_controller.dart';
import 'package:flutter/material.dart';

class PlatformGame extends StatefulWidget {
  const PlatformGame({Key? key}) : super(key: key);

  @override
  State<PlatformGame> createState() => _PlatformGameState();
}

class _PlatformGameState extends State<PlatformGame> {
  @override
  Widget build(BuildContext context) {
    return BonfireWidget(
      map: WorldMapByTiled(
        'platform/platform_map.tmj',
        objectsBuilder: {
          'frog': (properties) => FrogEnemy(
                position: properties.position,
              ),
          'gem': (properties) => GemDecoration(
                position: properties.position,
              ),
        },
      ),
      joystick: Joystick(
        keyboardConfig: KeyboardConfig(),
        directional: JoystickDirectional(
          color: Colors.green,
        ),
        actions: [
          JoystickAction(
            actionId: 1,
            margin: const EdgeInsets.all(50),
            color: Colors.green,
          ),
        ],
      ),
      components: [PlatformGameController()],
      backgroundColor: const Color(0xFF2fbdff),
      globalForces: [
        AccelerationForce2D(
          id: 'gravity',
          value: Vector2(0, 450),
        ),
      ],
      cameraConfig: CameraConfig(
        moveOnlyMapArea: true,
        zoom: 2.5,
        smoothCameraEnabled: true,
        smoothCameraSpeed: 3,
      ),
      player: FoxPlayer(
        position: Vector2(50 * 16, 3 * 16),
      ),
    );
  }
}
