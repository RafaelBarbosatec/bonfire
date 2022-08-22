import 'package:bonfire/bonfire.dart';

class TiledWorldData {
  final WorldMap map;
  final List<GameComponent>? components;

  TiledWorldData({required this.map, this.components});
}
