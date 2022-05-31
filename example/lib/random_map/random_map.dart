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

List<List<double>> generateNoise(Map<String, dynamic> data) {
  return noise2(
    data['w'],
    data['h'],
    seed: data['seed'],
    frequency: data['frequency'],
    noiseType: data['noiseType'],
    cellularDistanceFunction: data['cellularDistanceFunction'],
  );
}

class RandomMap extends StatefulWidget {
  final Vector2 size;
  const RandomMap({Key? key, required this.size}) : super(key: key);

  @override
  State<RandomMap> createState() => _RandomMapState();
}

class _RandomMapState extends State<RandomMap> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      DungeonMap.tileSize =
          max(constraints.maxHeight, constraints.maxWidth) / (kIsWeb ? 25 : 22);
      return FutureBuilder<List<List<double>>>(
          future: compute(
            generateNoise,
            {
              'h': widget.size.y.toInt(),
              'w': widget.size.x.toInt(),
              'seed': Random().nextInt(2000),
              'frequency': 0.02,
              'noiseType': NoiseType.PerlinFractal,
              'cellularDistanceFunction': CellularDistanceFunction.Natural,
            },
          ),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            return BonfireWidget(
              joystick: Joystick(
                directional: JoystickDirectional(
                  spriteBackgroundDirectional:
                      Sprite.load('joystick_background.png'),
                  spriteKnobDirectional: Sprite.load('joystick_knob.png'),
                  size: 100,
                  isFixed: false,
                ),
              ),
              cameraConfig: CameraConfig(
                moveOnlyMapArea: true,
              ),
              map: NoiseMapGenerator.generate(
                matrix: snapshot.data ?? [],
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
    });
  }
}
