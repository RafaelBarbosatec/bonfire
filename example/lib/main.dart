import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/tiled/tiled_world_map.dart';
import 'package:example/decoration/barrel_dragable.dart';
import 'package:example/decoration/torch.dart';
import 'package:example/enemy/goblin.dart';
import 'package:example/interface/knight_interface.dart';
import 'package:example/map/dungeon_map.dart';
import 'package:example/player/knight.dart';
import 'package:flame/animation.dart' as FlameAnimation;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.util.setLandscape();
  await Flame.util.fullScreen();
  runApp(
    MaterialApp(
      home: Game(),
    ),
  );
}

class Game extends StatelessWidget implements GameListener {
  final GameController _controller = GameController();

  @override
  Widget build(BuildContext context) {
    return BonfireTiledWidget(
      joystick: Joystick(
        directional: JoystickDirectional(
          spriteBackgroundDirectional: Sprite('joystick_background.png'),
          spriteKnobDirectional: Sprite('joystick_knob.png'),
          size: 100,
          isFixed: false,
        ),
        actions: [
          JoystickAction(
            actionId: 0,
            sprite: Sprite('joystick_atack.png'),
            align: JoystickActionAlign.BOTTOM_RIGHT,
            size: 80,
            margin: EdgeInsets.only(bottom: 50, right: 50),
          ),
          JoystickAction(
            actionId: 1,
            sprite: Sprite('joystick_atack_range.png'),
            spriteBackgroundDirection: Sprite('joystick_background.png'),
            enableDirection: true,
            size: 50,
            margin: EdgeInsets.only(bottom: 50, right: 160),
          )
        ],
      ),
      player: Knight(
        Position((8 * DungeonMap.tileSize), (12 * DungeonMap.tileSize)),
      ),
      interface: KnightInterface(),
      tiledMap: TiledWorldMap(
        'tiled/mapa1.json',
        forceTileSize: DungeonMap.tileSize,
      )
        ..registerObject('goblin', (x, y) => Goblin(Position(x, y)))
        ..registerObject('torch', (x, y) => Torch(Position(x, y)))
        ..registerObject('barrel', (x, y) => BarrelDraggable(Position(x, y))),
      background: BackgroundColorGame(Colors.blueGrey[900]),
//      gameController: _controller..setListener(this),
      lightingColorGame: Colors.black.withOpacity(0.5),
//      showCollisionArea: true,
//      showFPS: true,
    );
  }

  @override
  void updateGame() {}

  @override
  void changeCountLiveEnemies(int count) {
    if (count < 2) {
      _addEnemyInWorld();
    }
  }

  void _addEnemyInWorld() {
    double x = DungeonMap.tileSize * (4 + Random().nextInt(25));
    double y = DungeonMap.tileSize * (5 + Random().nextInt(3));

    Position position = Position(
      x,
      y,
    );
    _controller.addComponent(
      AnimatedObjectOnce(
        animation: FlameAnimation.Animation.sequenced(
          "smoke_explosin.png",
          6,
          textureWidth: 16,
          textureHeight: 16,
        ),
        position: Rect.fromLTWH(
          position.x,
          position.y,
          DungeonMap.tileSize,
          DungeonMap.tileSize,
        ),
      ),
    );

    _controller.addEnemy(
      Goblin(
        position,
      ),
    );
  }
}
