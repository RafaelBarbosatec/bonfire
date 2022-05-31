import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:example/manual_map/dungeon_map.dart';
import 'package:fast_noise/fast_noise.dart';
import 'package:flutter/foundation.dart';
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
/// on 31/05/22

class RandomMap extends StatelessWidget {
  const RandomMap({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      DungeonMap.tileSize =
          max(constraints.maxHeight, constraints.maxWidth) / (kIsWeb ? 25 : 22);
      return BonfireWidget(
        joystick: Joystick(
          directional: JoystickDirectional(
            spriteBackgroundDirectional: Sprite.load('joystick_background.png'),
            spriteKnobDirectional: Sprite.load('joystick_knob.png'),
            size: 100,
            isFixed: false,
          ),
        ),
        cameraConfig: CameraConfig(
          moveOnlyMapArea: true,
        ),
        map: NoiseMapGenerator.generate(
          matrix: noise2(
            100,
            100,
            seed: Random().nextInt(2000),
            frequency: 0.02,
            noiseType: NoiseType.PerlinFractal,
            cellularDistanceFunction: CellularDistanceFunction.Natural,
          ),
          builder: (prop) {
            Color? color = Colors.blue[900];
            if (prop.height > -0.35) {
              color = Colors.blue;
            }

            if (prop.height > -0.1) {
              color = Colors.orangeAccent;
            }

            if (prop.height > 0) {
              color = Colors.green;
            }

            if (prop.height > 0.35) {
              color = Colors.white;
            }
            return TileModel(
              x: prop.position.x,
              y: prop.position.y,
              width: DungeonMap.tileSize,
              height: DungeonMap.tileSize,
              color: color,
            );
          },
        ),
      );
    });
  }
}
