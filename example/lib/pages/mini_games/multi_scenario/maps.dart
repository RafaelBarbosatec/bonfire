import 'package:bonfire/bonfire.dart';
import 'package:bonfire/map/tiled/builder/tiled_world_builder.dart';
import 'package:example/pages/mini_games/multi_scenario/components/map_sensor.dart';
import 'package:example/pages/mini_games/multi_scenario/utils/constants/game_consts.dart';
import 'package:example/pages/mini_games/multi_scenario/utils/enums/map_id_enum.dart';

abstract class Maps {
  static get maps => {
        MapBiomeId.biome1.name: (context, args) {
          return MapItem(
            id: MapBiomeId.biome1.name,
            map: WorldMapByTiled(
              WorldMapReader.fromAsset(MultiScenarioAssets.mapBiome1),
              forceTileSize: Vector2.all(defaultTileSize),
              objectsBuilder: _objectBuilder,
            ),
          );
        },
        MapBiomeId.biome2.name: (context, args) => MapItem(
              id: MapBiomeId.biome2.name,
              map: WorldMapByTiled(
                WorldMapReader.fromAsset(MultiScenarioAssets.mapBiome2),
                forceTileSize: Vector2.all(defaultTileSize),
                objectsBuilder: _objectBuilder,
              ),
            ),
      };

  static Map<String, ObjectBuilder> get _objectBuilder => {
        'sensor': (p) {
          final parts = p.others['playerPosition'].toString().split(',');
          Vector2 playerPosition = Vector2(
            double.parse(parts[0]),
            double.parse(parts[1]),
          );
          return MapSensor(
            'sensor',
            p.position,
            p.size,
            p.others['nextMap'].toString(),
            playerPosition,
            Direction.fromName(p.others['playerDirection'].toString()),
          );
        },
      };
}

class MapArguments {
  final Vector2 playerPosition;
  final Direction playerDirection;

  MapArguments(this.playerPosition, this.playerDirection);
}
