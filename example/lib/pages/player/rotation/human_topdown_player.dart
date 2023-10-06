import 'package:bonfire/bonfire.dart';
import 'package:example/pages/player/rotation/human_topdown_player_spritesheet.dart';

class HumanTopdownPlayer extends RotationPlayer {
  HumanTopdownPlayer({
    required Vector2 position,
  }) : super(
          position: position,
          size: Vector2(24, 16),
          animIdle: HumanTopdownPlayerSpritesheet.idle(),
          animRun: HumanTopdownPlayerSpritesheet.run(),
          speed: 32,
        );
}
