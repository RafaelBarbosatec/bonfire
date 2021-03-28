import 'package:bonfire/bonfire.dart';
import 'package:example/map/dungeon_map.dart';
import 'package:flame/animation.dart' as FlameAnimation;
import 'package:flutter/material.dart';

class Torch extends GameDecoration with Lighting {
  Torch(Position position)
      : super.animation(
          FlameAnimation.Animation.sequenced(
            "itens/torch_spritesheet.png",
            6,
            textureWidth: 16,
            textureHeight: 16,
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
