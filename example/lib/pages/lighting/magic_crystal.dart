import 'package:bonfire/bonfire.dart';
import 'package:example/pages/mini_games/platform/platform_spritesheet.dart';
import 'package:flutter/material.dart';

/// Emissive light source.
///
/// Uses [LightingMode.additive] so it adds light on top of the scene instead of
/// cutting a hole in the ambient darkness. It keeps glowing even when the
/// ambient light is fully transparent (`lightingColorGame` off).
class MagicCrystal extends GameDecoration {
  MagicCrystal({required Vector2 position})
      : super.withAnimation(
          animation: PlatformSpritesheet.gem,
          position: position,
          size: Vector2.all(16),
          lightingConfig: LightingConfig(
            radius: 84,
            color: const Color(0xFF4FC3F7).withValues(alpha: 0.5),
            mode: LightingMode.additive,
            // Gradient falloff with a bright core.
            falloff: LightFalloff.smooth,
            innerRadius: 0.3,
            // The same color can be reused with a different intensity.
            intensity: 0.9,
            withPulse: true,
            pulseVariation: 0.14,
            pulseSpeed: 0.06,
            // `pulseCurve` is now actually applied.
            pulseCurve: Curves.easeInOut,
          ),
        );
}
