import 'package:bonfire/bonfire.dart';
import 'package:example/platform/platform_spritesheet.dart';
import 'package:flutter/services.dart';

class FoxPlayer extends SimplePlayer with BlockMovementCollision, HandleForces {
  bool jamping = true;

  FoxPlayer({
    required Vector2 position,
  }) : super(
            position: position,
            size: Vector2.all(33),
            speed: 50,
            animation: SimpleDirectionAnimation(
                idleRight: PlatformSpritesheet.playerIdleRight,
                runRight: PlatformSpritesheet.playerRunRight,
                runDown: PlatformSpritesheet.playerIdleRight,
                others: {
                  'jump_up': PlatformSpritesheet.playerJumpUp,
                  'jump_down': PlatformSpritesheet.playerJumpDown,
                })) {
    addForce(
      AccelerationForce2D(
        id: 'gravity',
        value: Vector2(0, 300),
      ),
    );
  }

  @override
  void joystickChangeDirectional(JoystickDirectionalEvent event) {
    if (event.directional == JoystickMoveDirectional.MOVE_UP ||
        event.directional == JoystickMoveDirectional.MOVE_UP_LEFT ||
        event.directional == JoystickMoveDirectional.MOVE_UP_RIGHT) {
      return;
    }
    super.joystickChangeDirectional(event);
  }

  @override
  void joystickAction(JoystickActionEvent event) {
    if (event.event == ActionEvent.DOWN &&
        event.id == LogicalKeyboardKey.space.keyId) {
      if (!jamping) {
        moveUp(speed: 150);
        jamping = true;
      }
    }
    super.joystickAction(event);
  }

  @override
  bool onBlockMovement(Set<Vector2> intersectionPoints, GameComponent other) {
    if (other.center.y > center.y) {
      jamping = false;
    }
    return super.onBlockMovement(intersectionPoints, other);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (jamping) {
      if (lastDirectionVertical == Direction.up) {
        animation?.playOther(
          'jump_up',
          flipX: lastDirectionHorizontal == Direction.left,
        );
      } else {
        animation?.playOther(
          'jump_down',
          flipX: lastDirectionHorizontal == Direction.left,
        );
      }
    }
  }

  @override
  Future<void> onLoad() {
    add(RectangleHitbox(size: size));
    return super.onLoad();
  }
}
