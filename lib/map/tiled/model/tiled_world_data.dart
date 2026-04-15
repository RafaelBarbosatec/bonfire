import 'package:bonfire/bonfire.dart';

class WorldBuildData {
  final WorldMap map;
  final List<GameComponent>? components;

  WorldBuildData({required this.map, this.components});
}
