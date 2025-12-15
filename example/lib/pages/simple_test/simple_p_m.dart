import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';

class SimplePM extends GameComponent
    with
        SimpleMovement,
        SimpleCollision,
        SimpleElasticCollision,
        PlayerControllerListener,
        SimpleForces {
  SimplePM({Vector2? position}) {
    size = Vector2(50, 50);
    this.position = position ?? Vector2(100, 0);
    speed = 100;

    makePingPongBall();
    enableEarthGravity();
    // enableHighFriction();
  }
  @override
  void render(Canvas canvas) {
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      size.x / 2,
      paint..color = Colors.blue,
    );
    super.render(canvas);
  }

  @override
  void onJoystickChangeDirectional(JoystickDirectionalEvent event) {
    switch (event.directional) {
      case JoystickMoveDirectional.MOVE_DOWN:
        moveDown();
      case JoystickMoveDirectional.MOVE_UP:
        moveUp();
      case JoystickMoveDirectional.MOVE_LEFT:
        moveLeft();
      case JoystickMoveDirectional.MOVE_RIGHT:
        moveRight();
      case JoystickMoveDirectional.IDLE:
      // stop();
      default:
        break;
    }
    super.onJoystickChangeDirectional(event);
  }

  @override
  Future<void> onLoad() {
    add(
      CircleHitbox(
        radius: size.x / 2,
        position: Vector2(0, 0),
        isSolid: true,
      ),
    );
    return super.onLoad();
  }
}

class SimpleCollitionT extends GameComponent {
  SimpleCollitionT() {
    size = Vector2(300, 50);
    position = Vector2(0, 250);
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      paint..color = Colors.red.withOpacity(0.5),
    );
    super.render(canvas);
  }

  @override
  Future<void> onLoad() {
    add(
      RectangleHitbox(
        size: size,
        position: Vector2(0, 0),
        isSolid: true,
      ),
    );
    return super.onLoad();
  }
}

class SimpleCollitionV extends GameComponent {
  SimpleCollitionV({Vector2? position}) {
    size = Vector2(50, 300);
    this.position = position ?? Vector2(-50, 0);
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      paint..color = Colors.red.withOpacity(0.5),
    );
    super.render(canvas);
  }

  @override
  Future<void> onLoad() {
    add(
      RectangleHitbox(
        size: size,
        position: Vector2(0, 0),
        isSolid: true,
      ),
    );
    return super.onLoad();
  }
}
