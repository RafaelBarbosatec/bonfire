import 'package:bonfire/bonfire.dart';
import 'package:example/pages/player/rotation/human_topdown_player_spritesheet.dart';

class HumanTopdownPlayer extends RotationPlayer with BlockMovementCollision {
  HumanTopdownPlayer({
    required Vector2 position,
  }) : super(
          position: position,
          size: Vector2(24, 16),
          animIdle: HumanTopdownPlayerSpritesheet.idle(),
          animRun: HumanTopdownPlayerSpritesheet.run(),
          speed: 32,
        );

  @override
  Future<void> onLoad() {
    add(CircleHitbox(radius: 8, position: Vector2(4, 0)));
    return super.onLoad();
  }
}
