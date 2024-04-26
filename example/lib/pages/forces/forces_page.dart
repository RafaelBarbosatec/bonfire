import 'package:bonfire/bonfire.dart';
import 'package:example/pages/forces/forces_gem.dart';
import 'package:example/pages/forces/forces_gem_bouncing.dart';
import 'package:flutter/material.dart';

class ForcesPage extends StatelessWidget {
  const ForcesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const tileSize = 16.0;
    return BonfireWidget(
      map: WorldMapByTiled(
        WorldMapReader.fromAsset('platform/simple_map_gem.tmj'),
        objectsBuilder: {
          'gem_acceleration': (prop) => ForcesGem(
                position: prop.position,
                text: 'AccelerationForce2D',
                force: AccelerationForce2D(
                  id: 'acc',
                  value: Vector2(0, 100),
                ),
              ),
          'gem_bouncing': (prop) => ForcesGemBouncing(
                position: prop.position,
              ),
          'gem_linear': (prop) => ForcesGem(
                position: prop.position,
                text: 'LinearForce2D',
                force: LinearForce2D(
                  id: 'linear',
                  value: Vector2(0, 10),
                ),
              ),
          'gem_resistence': (prop) => ForcesGem(
                position: prop.position,
                execMoveDown: true,
                text: 'ResistanceForce2D',
                force: ResistanceForce2D(
                  id: 'resi',
                  value: Vector2(0, 3),
                ),
              ),
        },
      ),
      overlayBuilderMap: {
        'resetButton': _buildButton,
      },
      initialActiveOverlays: const [
        'resetButton',
      ],
      cameraConfig: CameraConfig(
        zoom: getZoomFromMaxVisibleTile(context, tileSize, 28),
        initPosition: Vector2(tileSize * 7, tileSize * 5),
      ),
    );
  }

  Widget _buildButton(BuildContext context, BonfireGameInterface game) {
    return Container(
      alignment: Alignment.topCenter,
      margin: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: () {
          game.query<ForcesGem>().forEach((element) {
            element.reset();
          });
        },
        child: const Text('Reset position'),
      ),
    );
  }
}
