import 'package:bonfire/bonfire.dart';
import 'package:example/pages/collision/add_collision_component.dart';
import 'package:flutter/material.dart';

class CollisionPage extends StatelessWidget {
  const CollisionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const tileSize = 16.0;
    return BonfireWidget(
      map: WorldMapByTiled(
        WorldMapReader.fromAsset('tiled/collision.json'),
      ),
      components: [AddCollisionComponent()],
      cameraConfig: CameraConfig(
        zoom: getZoomFromMaxVisibleTile(context, tileSize, 28),
        initPosition: Vector2(tileSize * 10, tileSize * 6),
      ),
    );
  }
}
