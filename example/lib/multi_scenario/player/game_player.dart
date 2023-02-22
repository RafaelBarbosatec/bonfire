import 'package:bonfire/bonfire.dart';
import 'package:example/multi_scenario/utils/constants/game_consts.dart';

class GamePlayer extends SimplePlayer with ObjectCollision {
  static const sizePlayer = defaultTileSize * 1.5;
  double baseSpeed = sizePlayer * 2;

  GamePlayer(Vector2 position, SpriteSheet spriteSheet,
      {Direction initDirection = Direction.right})
      : super(
          animation: SimpleDirectionAnimation(
            idleUp:
                spriteSheet.createAnimation(row: 0, stepTime: 0.1).asFuture(),
            idleDown:
                spriteSheet.createAnimation(row: 1, stepTime: 0.1).asFuture(),
            idleLeft:
                spriteSheet.createAnimation(row: 2, stepTime: 0.1).asFuture(),
            idleRight:
                spriteSheet.createAnimation(row: 3, stepTime: 0.1).asFuture(),
            runUp:
                spriteSheet.createAnimation(row: 4, stepTime: 0.1).asFuture(),
            runDown:
                spriteSheet.createAnimation(row: 5, stepTime: 0.1).asFuture(),
            runLeft:
                spriteSheet.createAnimation(row: 6, stepTime: 0.1).asFuture(),
            runRight:
                spriteSheet.createAnimation(row: 7, stepTime: 0.1).asFuture(),
          ),
          size: Vector2.all(sizePlayer),
          position: position,
          initDirection: initDirection,
          life: 100,
          speed: sizePlayer * 2,
        ) {
    setupCollision(
      CollisionConfig(
        collisions: [
          CollisionArea.rectangle(
            size: Vector2(sizePlayer * 0.5, sizePlayer / 3),
            align: Vector2(sizePlayer * 0.25, sizePlayer * 0.65),
          ),
        ],
      ),
    );
  }

  @override
  void joystickChangeDirectional(JoystickDirectionalEvent event) {
    if (event.directional != JoystickMoveDirectional.IDLE) {
      speed = baseSpeed * event.intensity;
    }
    super.joystickChangeDirectional(event);
  }
}
