import 'package:bonfire/bonfire.dart';
import 'package:example/pages/player/simple/human_sprite_sheet.dart';

class HumanPlayer extends SimplePlayer with TileRecognizer {
  HumanPlayer({
    required Vector2 position,
  }) : super(
          animation: HumanSpritesheet().simpleAnimarion(),
          position: position,
          size: Vector2.all(24),
          speed: 32,
        );
}
