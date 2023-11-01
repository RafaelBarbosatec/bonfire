import 'package:bonfire/bonfire.dart';
import 'package:example/pages/mini_games/multi_scenario/utils/constants/game_consts.dart';

class GamePlayer extends SimplePlayer with BlockMovementCollision {
  static const sizePlayer = defaultTileSize * 1.5;
  double baseSpeed = sizePlayer * 2;

  GamePlayer(Vector2 position, SimpleDirectionAnimation? spriteSheet,
      {Direction initDirection = Direction.right})
      : super(
          animation: spriteSheet,
          size: Vector2.all(sizePlayer),
          position: position,
          initDirection: initDirection,
          life: 100,
          speed: sizePlayer * 2,
        );

  @override
  void onJoystickChangeDirectional(JoystickDirectionalEvent event) {
    if (event.directional != JoystickMoveDirectional.IDLE) {
      speed = baseSpeed * event.intensity;
    }
    super.onJoystickChangeDirectional(event);
  }

  @override
  Future<void> onLoad() {
    add(
      RectangleHitbox(
        size: Vector2(sizePlayer * 0.5, sizePlayer / 3),
        position: Vector2(sizePlayer * 0.25, sizePlayer * 0.65),
      ),
    );
    return super.onLoad();
  }
}
