import 'package:bonfire/bonfire.dart';
import 'package:example/top_down_game/robot_enemy.dart';
import 'package:example/top_down_game/soldier_player.dart';
import 'package:flutter/material.dart';

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
    return BonfireTiledWidget(
      map: TiledWorldMap('tiled/top_down/map.json', objectsBuilder: {
        'enemy': (prop) => RobotEnemy(prop.position),
      }),
      joystick: Joystick(
        directional: JoystickDirectional(),
      ),
      player: SoldierPlayer(Vector2.zero()),
      lightingColorGame: Colors.black.withOpacity(0.7),
    );
  }
}
