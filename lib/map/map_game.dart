import 'package:bonfire/map/tile.dart';
import 'package:bonfire/rpg_game.dart';
import 'package:flame/components/component.dart';
import 'package:flame/components/mixins/has_game_ref.dart';

abstract class MapGame extends Component with HasGameRef<RPGGame> {
  final Iterable<Tile> map;

  MapGame(this.map);

  List<Tile> getRendered();

  List<Tile> getCollisionsRendered();
}
