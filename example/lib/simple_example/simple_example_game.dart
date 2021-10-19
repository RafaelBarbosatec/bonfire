import 'package:bonfire/bonfire.dart';
import 'package:example/simple_example/my_enemy.dart';
import 'package:example/simple_example/my_player.dart';
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
/// on 19/10/21
class SimpleExampleGame extends StatelessWidget {
  const SimpleExampleGame({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BonfireTiledWidget(
      joystick: Joystick(
        directional: JoystickDirectional(),
      ),
      map: TiledWorldMap(
        'tiled/mapa2.json',
        forceTileSize: Size(32, 32),
        objectsBuilder: {
          'goblin': (properties) => MyEnemy(properties.position),
        },
      ),
      player: MyPlayer(Vector2(140, 140)),
    );
  }
}
