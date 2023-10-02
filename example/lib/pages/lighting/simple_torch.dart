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
            radius: 32,
            color: Colors.deepOrangeAccent.withOpacity(0.3),
            withPulse: true,
          ),
        );
}
