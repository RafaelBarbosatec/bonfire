import 'package:bonfire/bonfire.dart';
import 'package:example/manual_map/dungeon_map.dart';
import 'package:example/shared/util/common_sprite_sheet.dart';
import 'package:flutter/material.dart';

class Torch extends GameDecoration with Lighting {
  Torch(Vector2 position)
      : super.withAnimation(
          animation: CommonSpriteSheet.torchAnimated,
          size: Vector2.all(DungeonMap.tileSize),
          position: position,
        ) {
    setupLighting(
      LightingConfig(
        radius: width * 2,
        blurBorder: width,
        color: Colors.deepOrangeAccent.withOpacity(0.3),
        withPulse: true,
        align: Vector2(-width * 0.25, -width * 0.3),
      ),
    );
  }
}
