import 'package:bonfire/bonfire.dart';
import 'package:example/pages/player/rotation/human_topdown_player_spritesheet.dart';

/// Player used by the lighting example.
///
/// It intentionally has no light of its own: the lights are attached to the
/// scenario so the interaction between ambient darkness and lights stays easy
/// to see.
class DemoPlayer extends RotationPlayer with WithCollision {
  DemoPlayer({required Vector2 position})
      : super(
          position: position,
          size: Vector2(24, 16),
          animIdle: HumanTopdownPlayerSpritesheet.idle(),
          animRun: HumanTopdownPlayerSpritesheet.run(),
          speed: 36,
        );

  @override
  Future<void> onLoad() async {
    add(CircleHitbox(radius: 8, position: Vector2(-2, 0)));
    return super.onLoad();
  }
}
