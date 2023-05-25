import 'package:bonfire/bonfire.dart';
import 'package:example/platform/platform_spritesheet.dart';
import 'package:flutter/services.dart';

class FoxPlayer extends SimplePlayer with BlockMovementCollision, HandleForces {
  bool jamping = false;

  FoxPlayer({
    required Vector2 position,
  }) : super(
            position: position,
            size: Vector2.all(33),
            speed: 50,
            animation: SimpleDirectionAnimation(
              idleRight: PlatformSpritesheet.playerIdleRight,
              runRight: PlatformSpritesheet.playerRunRight,
              others: {
                'jump_up': PlatformSpritesheet.playerJumpUp,
                'jump_down': PlatformSpritesheet.playerJumpDown,
              },
            )) {
    addForce(
      AccelerationForce2D(
        id: 'gravity',
        value: Vector2(0, 400),
      ),
    );
  }

  @override
  void joystickChangeDirectional(JoystickDirectionalEvent event) {
    if (event.directional == JoystickMoveDirectional.MOVE_LEFT ||
        event.directional == JoystickMoveDirectional.MOVE_RIGHT ||
        event.directional == JoystickMoveDirectional.IDLE) {
      super.joystickChangeDirectional(event);
    }
  }

  @override
  void joystickAction(JoystickActionEvent event) {
    if (event.event == ActionEvent.DOWN &&
        (event.id == LogicalKeyboardKey.space.keyId || event.id == 1)) {
      if (!jamping) {
        moveUp(speed: 200);
        jamping = true;
      }
    }
    super.joystickAction(event);
  }

  @override
  bool onBlockMovement(Set<Vector2> intersectionPoints, GameComponent other) {
    if (jamping && lastDirectionVertical != Direction.up) {
      if (other.absoluteCenter.y > absoluteCenter.y) {
        jamping = false;
      }
    }

    return super.onBlockMovement(intersectionPoints, other);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!jamping) {
      jamping = lastDisplacement.y.abs() > speed * dt;
    }
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
    add(
      RectangleHitbox(
        size: size / 2,
        position: size / 4 + Vector2(0, 8),
        isSolid: true,
      ),
    );
    return super.onLoad();
  }

  @override
  void onPlayRunDownAnimation() {
    if (lastDirectionHorizontal == Direction.left) {
      animation?.play(SimpleAnimationEnum.idleLeft);
    } else {
      animation?.play(SimpleAnimationEnum.idleRight);
    }
  }
}
