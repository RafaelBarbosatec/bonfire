import 'package:bonfire/bonfire.dart';

class PlayerSpriteSheet {
  static Animation get idleLeft => Animation.sequenced(
        "player/knight_idle_left.png",
        6,
        textureWidth: 16,
        textureHeight: 16,
      );

  static Animation get idleRight => Animation.sequenced(
        "player/knight_idle.png",
        6,
        textureWidth: 16,
        textureHeight: 16,
      );

  static Animation get runRight => Animation.sequenced(
        "player/knight_run.png",
        6,
        textureWidth: 16,
        textureHeight: 16,
      );

  static Animation get runLeft => Animation.sequenced(
        "player/knight_run_left.png",
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
