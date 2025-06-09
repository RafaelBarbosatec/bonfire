import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/util/priority_layer.dart';

/// Base to create your custom game background
class GameBackground extends GameComponent {
  @override
  int get priority => LayerPriority.BACKGROUND;

  @override
  bool get isVisible => true;
}
