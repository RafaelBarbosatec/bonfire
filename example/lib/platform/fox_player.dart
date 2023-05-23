import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:flutter/services.dart';

class FoxPlayer extends SimplePlayer with BlockMovementCollision, HandleForces {
  FoxPlayer({
    required Vector2 position,
  }) : super(
          position: position,
          size: Vector2.all(16),
          speed: 50,
        ) {
    addForce(
      AccelerationForce2D(
        id: 'gravity',
        value: Vector2(0, 300),
      ),
    );
  }

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(
      Offset(width / 2, height / 2),
      width / 2,
      Paint()..color = const Color.fromARGB(255, 255, 47, 47),
    );
    super.render(canvas);
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
      moveUp(speed: 150);
    }
    super.joystickAction(event);
  }

  @override
  Future<void> onLoad() {
    add(RectangleHitbox(size: size));
    return super.onLoad();
  }
}
