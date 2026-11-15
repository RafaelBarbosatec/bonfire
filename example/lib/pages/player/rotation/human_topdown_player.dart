import 'package:bonfire/bonfire.dart';
import 'package:example/pages/player/rotation/human_topdown_player_spritesheet.dart';
import 'package:flutter/material.dart';

class HumanTopdownPlayer extends RotationPlayer
    with WithCollision, WithLighting {
  HumanTopdownPlayer({
    required Vector2 position,
  }) : super(
          position: position,
          size: Vector2(24, 16),
          animIdle: HumanTopdownPlayerSpritesheet.idle(),
          animRun: HumanTopdownPlayerSpritesheet.run(),
          speed: 32,
        ) {
    lighting.setup(
      LightingConfig(
        radius: size.x * 2,
        color: Colors.orange[100]!.withValues(alpha: 0.2),
        castShadows: true,
      ),
    );
  }

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
