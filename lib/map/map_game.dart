import 'package:bonfire/map/tile.dart';
import 'package:bonfire/util/joystick_controller.dart';
import 'package:flame/components/component.dart';

abstract class MapGame extends Component {
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
