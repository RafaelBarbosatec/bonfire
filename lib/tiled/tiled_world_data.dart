import 'package:bonfire/bonfire.dart';
import 'package:bonfire/enemy/enemy.dart';
import 'package:bonfire/map/map_world.dart';

class TiledWorldData {
  final MapWorld map;
  final List<Enemy> enemies;
  final List<GameDecoration> decorations;

  TiledWorldData({this.map, this.enemies, this.decorations});
}
