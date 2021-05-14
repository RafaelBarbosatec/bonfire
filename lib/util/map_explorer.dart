import 'package:bonfire/camera/camera.dart';
import 'package:bonfire/joystick/joystick_controller.dart';

import '../bonfire.dart';

class MapExplorer implements JoystickListener {
  final Camera camera;

  MapExplorer(this.camera);

  @override
  void joystickAction(JoystickActionEvent event) {}

  @override
  void joystickChangeDirectional(JoystickDirectionalEvent event) {
    double speed = 8 * event.intensity;

    switch (event.directional) {
      case JoystickMoveDirectional.MOVE_UP:
        camera.moveTop(speed);
        break;
      case JoystickMoveDirectional.MOVE_RIGHT:
        camera.moveRight(speed);
        break;
      case JoystickMoveDirectional.MOVE_DOWN:
        camera.moveDown(speed);
        break;
      case JoystickMoveDirectional.MOVE_LEFT:
        camera.moveUp(speed);
        break;
      case JoystickMoveDirectional.MOVE_UP_LEFT:
        camera.moveUp(speed * 0.8);
        camera.moveTop(speed * 0.8);
        break;
      case JoystickMoveDirectional.MOVE_UP_RIGHT:
        camera.moveRight(speed * 0.8);
        camera.moveTop(speed * 0.8);
        break;
      case JoystickMoveDirectional.MOVE_DOWN_RIGHT:
        camera.moveRight(speed * 0.8);
        camera.moveDown(speed * 0.8);
        break;
      case JoystickMoveDirectional.MOVE_DOWN_LEFT:
        camera.moveUp(speed * 0.8);
        camera.moveDown(speed * 0.8);
        break;
      case JoystickMoveDirectional.IDLE:
        break;
    }
  }

  @override
  void moveTo(Vector2 position) {}
}
