import 'package:bonfire/bonfire.dart';
import 'package:example/pages/player/rotation/human_topdown_player_spritesheet.dart';
import 'package:flutter/material.dart';

/// Player used by the lighting example.
///
/// Its light is an [ArcLightingType] that follows the component `angle`
/// (`useComponentAngle: true`), so it behaves like a flashlight.
class LightingPlayer extends RotationPlayer with WithCollision, WithLighting {
  LightingPlayer({required Vector2 position})
      : super(
          position: position,
          size: Vector2(24, 16),
          animIdle: HumanTopdownPlayerSpritesheet.idle(),
          animRun: HumanTopdownPlayerSpritesheet.run(),
          speed: 36,
        ) {
    lighting.setup(flashlight);
  }

  /// Narrow light cone that follows the player facing direction.
  static final LightingConfig flashlight = LightingConfig(
    radius: 84,
    color: const Color(0xFFFFF3C4).withValues(alpha: 0.16),
    // A crisp edge: `blurBorder: 0` no longer creates an invalid blur.
    blurBorder: 0,
    type: LightingType.arc(
      startRadAngle: -0.45,
      endRadAngle: 0.9,
      isCenter: true,
    ),
    useComponentAngle: true,
  );

  /// Classic round light around the player.
  static final LightingConfig omni = LightingConfig(
    radius: 64,
    color: const Color(0xFFBFE9FF).withValues(alpha: 0.12),
    blurBorder: 20,
  );

  @override
  Future<void> onLoad() async {
    add(CircleHitbox(radius: 8, position: Vector2(-2, 0)));
    return super.onLoad();
  }
}
