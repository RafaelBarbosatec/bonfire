import 'package:bonfire/bonfire.dart';
import 'package:example/shared/util/common_sprite_sheet.dart';
import 'package:flutter/material.dart';

/// Tocha que **projeta sombras** nas paredes.
///
/// Mostra o outro extremo das configurações: gradiente (`LightFalloff.linear`),
/// flicker e `castShadows`. As paredes que bloqueiam a luz são registradas na
/// página (`gameRef.lighting.addOccluder`), não aqui.
class ShadowTorch extends GameDecoration {
  ShadowTorch({required Vector2 position})
      : super.withAnimation(
          animation: CommonSpriteSheet.torchAnimated,
          size: Vector2.all(16),
          position: position,
          lightingConfig: LightingConfig(
            radius: 64,
            color: Colors.deepOrange.withValues(alpha: 0.42),
            align: Vector2(0, -6),
            // Borda suave sem `MaskFilter.blur`.
            falloff: LightFalloff.linear,
            innerRadius: 0.45,
            withPulse: true,
            pulseVariation: 0.05,
            pulseCurve: Curves.easeInOut,
            // Candle-like flicker applied to radius and intensity.
            flicker: const LightFlicker(
              frequency: 2,
              amplitude: 0.05,
              seed: 3,
            ),
            // Walls registered in the game block this light.
            castShadows: true,
          ),
        );
}
