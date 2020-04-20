import 'package:bonfire/map/tile.dart';
import 'package:bonfire/rpg_game.dart';
import 'package:flame/components/component.dart';
import 'package:flame/components/mixins/has_game_ref.dart';

abstract class MapGame extends Component with HasGameRef<RPGGame> {
  Iterable<Tile> tiles;

  MapGame(this.tiles);

  List<Tile> getRendered();

  List<Tile> getCollisionsRendered();

  void updateTiles(Iterable<Tile> map);
}
