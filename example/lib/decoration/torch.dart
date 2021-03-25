import 'package:bonfire/bonfire.dart';
import 'package:example/map/dungeon_map.dart';
import 'package:flutter/material.dart';

class Torch extends GameDecoration with Lighting {
  Torch(Vector2 position)
      : super.animation(
          SpriteAnimation.load(
            "itens/torch_spritesheet.png",
            SpriteAnimationData.sequenced(
              amount: 6,
              stepTime: 0.1,
              textureSize: Vector2(16, 16),
            ),
          ),
          width: DungeonMap.tileSize,
          height: DungeonMap.tileSize,
          position: position,
        ) {
    lightingConfig = LightingConfig(
      radius: width * 1.5,
      blurBorder: width * 1.5,
      color: Colors.deepOrangeAccent.withOpacity(0.2),
    );
  }
}
