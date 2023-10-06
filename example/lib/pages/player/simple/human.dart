import 'package:bonfire/bonfire.dart';
import 'package:example/shared/util/person_sprite_sheet.dart';

class HumanPlayer extends SimplePlayer {
  HumanPlayer({
    required Vector2 position,
  }) : super(
          animation: PersonSpritesheet().simpleAnimation(),
          position: position,
          size: Vector2.all(24),
          speed: 32,
        );
}
