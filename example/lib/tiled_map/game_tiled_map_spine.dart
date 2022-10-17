import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/player/spine_player.dart';
import 'package:example/manual_map/dungeon_map.dart';
import 'package:example/shared/decoration/barrel_dragable.dart';
import 'package:example/shared/decoration/chest.dart';
import 'package:example/shared/decoration/spikes.dart';
import 'package:example/shared/decoration/torch.dart';
import 'package:example/shared/enemy/goblin.dart';
import 'package:example/shared/interface/bar_life_widget.dart';
import 'package:example/shared/interface/knight_interface.dart';
import 'package:example/shared/npc/critter/critter.dart';
import 'package:example/shared/npc/wizard/wizard.dart';
import 'package:example/shared/player/knight.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../shared/decoration/column.dart';

class GameTiledMapWithSpine extends StatelessWidget {
  final int map;
  final SpinePlayer player;
  const GameTiledMapWithSpine({Key? key, this.map = 1,required this.player}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        DungeonMap.tileSize = max(constraints.maxHeight, constraints.maxWidth) /
            (kIsWeb ? 25 : 22);
        return BonfireWidget(
          joystick: Joystick(
            keyboardConfig: KeyboardConfig(
              keyboardDirectionalType: KeyboardDirectionalType.wasdAndArrows,
              acceptedKeys: [
                LogicalKeyboardKey.space,
              ],
            ),
            directional: JoystickDirectional(
              spriteBackgroundDirectional: Sprite.load(
                'joystick_background.png',
              ),
              spriteKnobDirectional: Sprite.load('joystick_knob.png'),
              size: 100,
              isFixed: false,
            ),

            actions: [
              JoystickAction(
                actionId: PlayerAttackType.AttackMelee,
                sprite: Sprite.load('joystick_atack.png'),
                align: JoystickActionAlign.BOTTOM_RIGHT,
                size: 80,
                margin: EdgeInsets.only(bottom: 50, right: 50),
              ),
              JoystickAction(
                actionId: PlayerAttackType.AttackRange,
                sprite: Sprite.load('joystick_atack_range.png'),
                spriteBackgroundDirection: Sprite.load(
                  'joystick_background.png',
                ),
                enableDirection: true,
                size: 50,
                margin: EdgeInsets.only(bottom: 50, right: 160),
              )
            ],
          ),
          showCollisionArea: true,
          player: player,
          interface: KnightInterface(),
          map: WorldMapByTiled(
            'tiled/mapa$map.json',
            forceTileSize: Vector2(DungeonMap.tileSize, DungeonMap.tileSize),
            objectsBuilder: {
              'goblin': (properties) => Goblin(properties.position),
              'torch': (properties) => Torch(properties.position),
              'barrel': (properties) => BarrelDraggable(properties.position),
              'spike': (properties) => Spikes(properties.position),
              'column': (properties) => ColumnDecoration(properties.position),
              'chest': (properties) => Chest(properties.position),
              'critter': (properties) => Critter(properties.position),
              'wizard': (properties) => Wizard(properties.position),
            },
          ),
          // lightingColorGame: Colors.black.withOpacity(0.7),
          overlayBuilderMap: {
            'barLife': (context, game) => BarLifeWidget(),
            'miniMap': (context, game) => MiniMap(
                  game: game,
                  margin: EdgeInsets.all(20),
                  borderRadius: BorderRadius.circular(10),
                  size: Vector2.all(
                    min(constraints.maxHeight, constraints.maxWidth) / 3,
                  ),
                  border: Border.all(color: Colors.white.withOpacity(0.5)),
                ),
          },
          initialActiveOverlays: [
            'barLife',
            'miniMap',
          ],
          cameraConfig: CameraConfig(
            smoothCameraEnabled: true,
            smoothCameraSpeed: 2,
          ),
        );
      },
    );
  }
}
