import 'package:bonfire/bonfire.dart';
import 'package:example/shared/util/common_sprite_sheet.dart';
import 'package:flutter/material.dart';

class SimpleTorch extends GameDecoration {
  SimpleTorch(Vector2 position)
      : super.withAnimation(
          animation: CommonSpriteSheet.torchAnimated,
          size: Vector2.all(16),
          position: position,
          lightingConfig: LightingConfig(
            radius: 40,
            color: Colors.deepOrangeAccent.withValues(alpha: 0.38),
            // Offset of the light relative to the component center.
            align: Vector2(0, -6),
            // Gradient falloff: softer and cheaper than `MaskFilter.blur`.
            falloff: LightFalloff.linear,
            innerRadius: 0.4,
            withPulse: true,
            pulseVariation: 0.06,
            // The configured curve is used by the pulse animation.
            pulseCurve: Curves.easeInOut,
            // Candle-like flicker applied to radius and intensity.
            flicker: const LightFlicker(
              frequency: 2,
              amplitude: 0.05,
              seed: 3,
            ),
          ),
        );
}
