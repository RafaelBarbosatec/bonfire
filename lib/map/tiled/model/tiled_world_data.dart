import 'package:bonfire/bonfire.dart';

class WorldBuildData {
  final WorldMap map;
  final List<GameComponent>? components;

  /// Decorations that must render as children of the tile map (e.g. oversized
  /// tiles from Tiled whose stacking must follow the layer order instead of
  /// the dynamic Y-sort used by game-level components).
  final List<GameComponent>? mapChildren;

  WorldBuildData({
    required this.map,
    this.components,
    this.mapChildren,
  });
}
