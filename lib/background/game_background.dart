import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/util/priority_layer.dart';

class GameBackground extends GameComponent {
  @override
  int get priority => LayerPriority.BACKGROUND;

  @override
  bool get isHud => true;
}
