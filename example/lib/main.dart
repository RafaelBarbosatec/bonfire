import 'dart:math';

import 'package:bonfire/bonfire.dart';
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
  static const sizeTile = 32.0;

  final GameController _controller = GameController();

  @override
  Widget build(BuildContext context) {
    return BonfireWidget(
      joystick: Joystick(
        pathSpriteBackgroundDirectional: 'joystick_background.png',
        pathSpriteKnobDirectional: 'joystick_knob.png',
        sizeDirectional: 100,
        marginLeftDirectional: 150,
        actions: [
          JoystickAction(
            actionId: 0,
            pathSprite: 'joystick_atack.png',
            size: 80,
            margin: EdgeInsets.only(bottom: 50, right: 50),
          ),
          JoystickAction(
            actionId: 1,
            pathSprite: 'joystick_atack_range.png',
            size: 50,
            margin: EdgeInsets.only(bottom: 50, right: 160),
          )
        ],
      ),
      player: Knight(
        initPosition: Position(5 * sizeTile, 6 * sizeTile),
      ),
      interface: KnightInterface(),
      map: DungeonMap.map(),
      decorations: DungeonMap.decorations(),
      enemies: DungeonMap.enemies(),
      background: BackgroundColorGame(Colors.blueGrey[900]),
      gameController: _controller..setListener(this),
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
    double x = sizeTile * (2 + Random().nextInt(27));
    double y = sizeTile * (5 + Random().nextInt(3));

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
          sizeTile,
          sizeTile,
        ),
      ),
    );

    _controller.addEnemy(
      Goblin(
        initPosition: position,
      ),
    );
  }
}
