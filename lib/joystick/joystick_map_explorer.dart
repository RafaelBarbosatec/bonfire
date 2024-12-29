import 'package:bonfire/bonfire.dart';
import 'package:bonfire/camera/bonfire_camera.dart';

class JoystickMapExplorer with PlayerControllerListener {
  final BonfireCamera camera;

  JoystickMapExplorer(this.camera);

  @override
  void onJoystickAction(JoystickActionEvent event) {}

  @override
  void onJoystickChangeDirectional(JoystickDirectionalEvent event) {
    final speed = 4 * event.intensity;

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
}
