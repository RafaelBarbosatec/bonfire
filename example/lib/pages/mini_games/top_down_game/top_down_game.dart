import 'package:bonfire/bonfire.dart';
import 'package:example/pages/mini_games/top_down_game/robot_enemy.dart';
import 'package:example/pages/mini_games/top_down_game/soldier_player.dart';
import 'package:flutter/material.dart';

import 'armchair_decoration.dart';

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
/// on 27/01/22
class TopDownGame extends StatelessWidget {
  const TopDownGame({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BonfireWidget(
      map: WorldMapByTiled(
        WorldMapReader.fromAsset('tiled/top_down/map.json'),
        objectsBuilder: {
          'enemy': (prop) => ZombieEnemy(prop.position),
          'armchair': (prop) => ArmchairDecoration(prop.position),
        },
      ),
      playerControllers: [
        Joystick(
          directional: JoystickDirectional(),
          actions: [
            JoystickAction(
              actionId: 1,
              margin: const EdgeInsets.all(50),
            ),
          ],
        ),
      ],
      cameraConfig: CameraConfig(
        moveOnlyMapArea: true,
        zoom: getZoomFromMaxVisibleTile(context, 68, 12),
      ),
      player: SoldierPlayer(Vector2(64 * 17, 64 * 4)),
      lightingColorGame: Colors.black.withOpacity(0.7),
    );
  }
}
