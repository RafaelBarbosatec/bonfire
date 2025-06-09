import 'package:bonfire/bonfire.dart';
import 'package:example/pages/mini_games/simple_example/my_enemy.dart';
import 'package:flutter/material.dart';

class PerformanceGame extends StatelessWidget {
  static const countEnemies = 100;
  const PerformanceGame({Key? key}) : super(key: key);

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
                interval: 100,
                builder: (position) {
                  return MyEnemy(
                    position,
                    withCollision: false,
                  );
                },
                spawnCondition: (game) {
                  return game.query<MyEnemy>().length < countEnemies;
                },
              ),
        },
      ),
      cameraConfig: CameraConfig(
        moveOnlyMapArea: true,
        zoom: getZoomFromMaxVisibleTile(context, 32, 20),
      ),
      interface: MyFpsLabel(),
      backgroundColor: const Color.fromARGB(255, 10, 53, 89),
    );
  }
}

class MyFpsLabel extends GameInterface {
  late TextComponent textCount;
  @override
  void onMount() {
    textCount = TextComponent(
      text: 'COUNT: 0',
      position: Vector2(100, 0),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
      ),
    );
    add(textCount);
    add(FpsTextComponent());
    super.onMount();
  }

  @override
  void update(double dt) {
    textCount.text = 'COUNT: ${gameRef.query<MyEnemy>().length}';
    super.update(dt);
  }
}
