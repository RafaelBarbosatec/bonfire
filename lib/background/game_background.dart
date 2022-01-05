import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/util/priority_layer.dart';
import 'package:flame/components.dart';

/// Base to create your custom game background
class GameBackground extends GameComponent {
  @override
  int get priority => LayerPriority.BACKGROUND;

  @override
  PositionType get positionType => PositionType.viewport;
}
