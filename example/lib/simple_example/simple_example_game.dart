import 'package:bonfire/bonfire.dart';
import 'package:example/shared/decoration/barrel_dragable.dart';
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
    return BonfireWidget(
      joystick: Joystick(
        keyboardConfig: KeyboardConfig(),
        directional: JoystickDirectional(),
      ),
      map: WorldMapByTiled(
        'tiled/mapa2.json',
        forceTileSize: Vector2.all(32),
        objectsBuilder: {
          'goblin': (properties) => MyEnemy(properties.position),
        },
      ),
      components: [
        BarrelDraggable(Vector2(300, 150)),
      ],
      player: MyPlayer(Vector2(140, 140)),
      cameraConfig: CameraConfig(
        moveOnlyMapArea: true,
        zoom: MediaQuery.of(context).size.width / (32 * 15),
      ),
      backgroundColor: const Color.fromARGB(255, 10, 53, 89),
    );
  }
}
