import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:turn_game/characters/ghost.dart';
import 'package:turn_game/characters/hero.dart';
import 'package:turn_game/characters/knight.dart';
import 'package:turn_game/characters/necromancer.dart';
import 'package:turn_game/interface/turn_painel.dart';
import 'package:turn_game/util/move_camera_controller.dart';
import 'package:turn_game/util/turn_manager.dart';

class TurnGame extends StatelessWidget {
  const TurnGame({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraint) {
      return BonfireWidget(
        map: WorldMapByTiled(
          WorldMapReader.fromAsset('map/map1.tmj'),
          objectsBuilder: {
            'hero': ((p) => PHero(position: p.position)),
            'ghost': ((p) => Ghost(position: p.position)),
            'knight': ((p) => Knight(position: p.position)),
            'necro': ((p) => Necromancer(position: p.position)),
          },
        ),
        overlayBuilderMap: {
          'painel': (context, game) => const TurnPainel(),
        },
        initialActiveOverlays: const ['painel'],
        cameraConfig: CameraConfig(
          moveOnlyMapArea: true,
          zoom: getZoomFromMaxVisibleTile(context, 16, 20),
        ),
        components: [
          TurnManager.instance,
          MoveCameraController(),
        ],
      );
    });
  }
}
