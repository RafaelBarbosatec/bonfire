import 'package:bonfire/joystick/joystick_controller.dart';
import 'package:bonfire/map/tile.dart';
import 'package:bonfire/rpg_game.dart';
import 'package:flame/components/component.dart';
import 'package:flame/components/mixins/has_game_ref.dart';

abstract class MapGame extends Component with HasGameRef<RPGGame> {
  final Iterable<Tile> map;

  MapGame(this.map);

  bool isMaxTop();

  bool isMaxLeft();

  bool isMaxRight();

  bool isMaxBottom();

  List<Tile> getRendered();

  List<Tile> getCollisionsRendered();

  void moveCamera(double displacement, JoystickMoveDirectional directional);
}
