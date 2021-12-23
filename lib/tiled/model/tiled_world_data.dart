import 'package:bonfire/bonfire.dart';

class TiledWorldData {
  final MapWorld map;
  final List<GameComponent>? components;

  TiledWorldData({required this.map, this.components});
}
