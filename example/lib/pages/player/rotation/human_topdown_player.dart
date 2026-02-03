import 'package:bonfire/bonfire.dart';
import 'package:example/pages/player/rotation/human_topdown_player_spritesheet.dart';

class HumanTopdownPlayer extends RotationPlayer with SimpleCollision {
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
    add(CircleHitbox(radius: 8, position: Vector2(-2, 0)));
    return super.onLoad();
  }

  @override
  void onMount() {
    anchor = const Anchor(0.3, 0.5);
    super.onMount();
  }
}
