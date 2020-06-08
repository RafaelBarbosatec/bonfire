import 'package:bonfire/bonfire.dart';
import 'package:example/map/dungeon_map.dart';
import 'package:flame/animation.dart' as FlameAnimation;

class Torch extends GameDecoration with WithLighting {
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
          initPosition: position,
        ) {
    lightingConfig = LightingConfig(
      gameComponent: this,
      radius: width * 1.5,
      blurBorder: width / 2,
    );
  }
}
