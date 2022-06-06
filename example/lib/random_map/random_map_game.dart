import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:example/manual_map/dungeon_map.dart';
import 'package:example/random_map/map_generator.dart';
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

class RandomMapGame extends StatefulWidget {
  final Vector2 size;
  const RandomMapGame({Key? key, required this.size}) : super(key: key);

  @override
  State<RandomMapGame> createState() => _RandomMapGameState();
}

class _RandomMapGameState extends State<RandomMapGame> {
  MapGenerator? _mapGenerator;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        DungeonMap.tileSize = max(constraints.maxHeight, constraints.maxWidth) /
            (kIsWeb ? 25 : 22);
        if (_mapGenerator == null) {
          _mapGenerator = MapGenerator(widget.size, DungeonMap.tileSize);
        }
        return BonfireWidget(
          joystick: Joystick(
            directional: JoystickDirectional(
              size: 100,
              isFixed: false,
            ),
          ),
          player: _mapGenerator!.getPlayer(),
          cameraConfig: CameraConfig(
            moveOnlyMapArea: true,
          ),
          map: _mapGenerator!.buildMap(),
          components: _mapGenerator!.buildComponents(),
        );
      },
    );
  }
}
