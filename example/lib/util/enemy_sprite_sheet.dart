import 'package:bonfire/bonfire.dart';

class EnemySpriteSheet {
  static Animation get idleLeft => Animation.sequenced(
        "enemy/goblin_idle_left.png",
        6,
        textureWidth: 16,
        textureHeight: 16,
      );

  static Animation get idleRight => Animation.sequenced(
        "enemy/goblin_idle.png",
        6,
        textureWidth: 16,
        textureHeight: 16,
      );

  static Animation get runRight => Animation.sequenced(
        "enemy/goblin_run_right.png",
        6,
        textureWidth: 16,
        textureHeight: 16,
      );

  static Animation get runLeft => Animation.sequenced(
        "enemy/goblin_run_left.png",
        6,
        textureWidth: 16,
        textureHeight: 16,
      );

  static SimpleDirectionAnimation get simpleDirectionAnimation =>
      SimpleDirectionAnimation(
        idleLeft: idleLeft,
        idleRight: idleRight,
        runLeft: runLeft,
        runRight: runRight,
      );
}
