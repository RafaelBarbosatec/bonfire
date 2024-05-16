import 'package:bonfire/bonfire.dart';
import 'package:example/pages/mini_games/simple_example/my_enemy.dart';
import 'package:example/pages/mini_games/simple_example/my_player.dart';
import 'package:example/shared/decoration/barrel_dragable.dart';
import 'package:example/shared/decoration/potion_life.dart';
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
      playerControllers: [
        Joystick(
          directional: JoystickDirectional(),
        ),
      ],
      map: WorldMapByTiled(
        WorldMapReader.fromAsset('tiled/mapa2.json'),
        forceTileSize: Vector2.all(32),
        objectsBuilder: {
          'goblin': (properties) => MyEnemy(properties.position),
          'spawn': (properties) => ComponentSpawner(
                position: properties.position,
                area: properties.area,
                interval: 500,
                builder: (position) {
                  return PotionLife(position, 1, size: Vector2.all(10));
                },
                spawnCondition: (game) {
                  return game.query<PotionLife>().length < 10;
                },
              ),
        },
      ),
      components: [
        BarrelDraggable(Vector2(300, 150)),
      ],
      player: MyPlayer(Vector2(140, 140)),
      cameraConfig: CameraConfig(
        moveOnlyMapArea: true,
        zoom: getZoomFromMaxVisibleTile(context, 32, 15),
      ),
      backgroundColor: const Color.fromARGB(255, 10, 53, 89),
    );
  }
}
