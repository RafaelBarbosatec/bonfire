import 'package:bonfire/bonfire.dart';
import 'package:example/shared/util/common_sprite_sheet.dart';
import 'package:flutter/material.dart';

/// Tocha do exemplo **padrão** de iluminação.
///
/// É a configuração clássica do `LightingConfig`: círculo com `blurBorder`,
/// pulse e `align`. Sem gradiente, sem flicker e sem sombras — o objetivo é
/// servir de referência do comportamento que já existia.
class SimpleTorch extends GameDecoration {
  SimpleTorch(Vector2 position)
      : super.withAnimation(
          animation: CommonSpriteSheet.torchAnimated,
          size: Vector2.all(16),
          position: position,
          lightingConfig: LightingConfig(
            radius: 34,
            color: Colors.deepOrangeAccent.withValues(alpha: 0.3),
            blurBorder: 18,
            // Offset of the light relative to the component center.
            align: Vector2(0, -6),
            withPulse: true,
            pulseVariation: 0.12,
            // The configured curve is used by the pulse animation.
            pulseCurve: Curves.easeInOut,
          ),
        );
}
