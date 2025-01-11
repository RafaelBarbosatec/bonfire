import 'package:bonfire/bonfire.dart';

class Spritesheet {
  static Future<SpriteAnimation> get flapDown {
    return Sprite.load('bluebird-downflap.png').toAnimation();
  }

  static Future<SpriteAnimation> get flapUp {
    return Sprite.load('bluebird-upflap.png').toAnimation();
  }

  static Future<SpriteAnimation> get flapMidle {
    return Sprite.load('bluebird-midflap.png').toAnimation();
  }

  static Future<Sprite> get pipe {
    return Sprite.load('pipe-green.png');
  }
}
